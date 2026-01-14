package com.bookmanagement.service.impl;

import com.bookmanagement.dao.BookMapper;
import com.bookmanagement.dao.BorrowMapper;
import com.bookmanagement.dao.UserMapper;
import com.bookmanagement.entity.Book;
import com.bookmanagement.entity.BorrowRecord;
import com.bookmanagement.entity.User;
import com.bookmanagement.service.BorrowService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.SimpleDateFormat;
import java.util.*;

@Service
@Transactional
public class BorrowServiceImpl implements BorrowService {

    @Autowired
    private UserMapper userMapper;

    private static final Logger logger = LoggerFactory.getLogger(BorrowServiceImpl.class);

    @Autowired
    private BorrowMapper borrowMapper;

    @Autowired
    private BookMapper bookMapper;

    @Override
    @Transactional
    public boolean borrowBook(Integer userId, Integer bookId, Integer days) {
        try {
            logger.info("开始借阅图书，用户ID: {}, 图书ID: {}, 天数: {}", userId, bookId, days);

            // 检查图书是否存在
            Book book = bookMapper.selectBookById(bookId);
            if (book == null) {
                logger.warn("图书不存在，图书ID: {}", bookId);
                return false;
            }

            // 检查图书状态 - 维护中的图书不能借阅
            if ("MAINTENANCE".equals(book.getStatus())) {
                logger.warn("图书维护中，不能借阅，图书ID: {}", bookId);
                return false;
            }

            if (book.getAvailableCopies() <= 0) {
                logger.warn("图书已全部借出，图书ID: {}", bookId);
                return false;
            }

            // 先检查用户是否有逾期未还的图书
            List<BorrowRecord> overdueRecords = borrowMapper.selectOverdueRecords();
            boolean hasOverdue = false;
            for (BorrowRecord record : overdueRecords) {
                if (record.getUserId().equals(userId)) {
                    hasOverdue = true;
                    break;
                }
            }

            if (hasOverdue) {
                logger.warn("用户有逾期未还的图书，无法借阅新书，用户ID: {}", userId);
                // 抛出特定异常，Controller可以捕获并显示相应消息
                throw new RuntimeException("您有逾期未还的图书，请先归还逾期图书！");
            }

            // 检查用户是否已经借阅了该书
            BorrowRecord existingRecord = borrowMapper.checkBorrowed(userId, bookId);
            if (existingRecord != null && !"RETURNED".equals(existingRecord.getStatus())) {
                logger.warn("用户已借阅该图书，用户ID: {}, 图书ID: {}", userId, bookId);

                if ("OVERDUE".equals(existingRecord.getStatus())) {
                    throw new RuntimeException("该书您已逾期未还，请先归还！");
                }

                return false; // 普通情况：已借阅但未逾期
            }

            // 计算借阅日期和应还日期
            Calendar calendar = Calendar.getInstance();
            Date borrowDate = calendar.getTime();

            calendar.add(Calendar.DAY_OF_MONTH, days);
            Date dueDate = calendar.getTime();

            // 创建借阅记录
            BorrowRecord record = new BorrowRecord();
            record.setUserId(userId);
            record.setBookId(bookId);
            record.setBorrowDate(borrowDate);
            record.setDueDate(dueDate);
            record.setStatus("BORROWED");

            // 减少图书可用数量
            book.setAvailableCopies(book.getAvailableCopies() - 1);
            if (book.getAvailableCopies() <= 0) {
                book.setStatus("BORROWED");
            }

            // 开启事务，确保两个操作都成功
            bookMapper.updateAvailableCopies(bookId, book.getAvailableCopies());
            int insertResult = borrowMapper.insertBorrowRecord(record);

            logger.info("借阅成功，用户ID: {}, 图书ID: {}, 应还日期: {}, 插入结果: {}",
                    userId, bookId, dueDate, insertResult);
            return insertResult > 0;
        } catch (Exception e) {
            logger.error("借阅图书失败，用户ID: {}, 图书ID: {}", userId, bookId, e);
            throw e;
        }
    }

    @Override
    @Transactional
    public boolean returnBook(Integer recordId) {
        try {
            logger.info("开始还书操作，记录ID: {}", recordId);

            BorrowRecord record = borrowMapper.selectBorrowRecordById(recordId);
            if (record == null) {
                logger.error("借阅记录不存在，ID: {}", recordId);
                return false;
            }

            if ("RETURNED".equals(record.getStatus())) {
                logger.warn("图书已归还，记录ID: {}", recordId);
                return false;
            }

            logger.debug("找到借阅记录，用户ID: {}, 图书ID: {}",
                    record.getUserId(), record.getBookId());

            // 更新借阅记录
            record.setReturnDate(new Date());
            record.setStatus("RETURNED");
            int updateResult = borrowMapper.updateBorrowRecord(record);
            logger.debug("更新借阅记录结果: {}", updateResult);

            if (updateResult <= 0) {
                logger.error("更新借阅记录失败");
                return false;
            }

            // 增加图书可用数量
            Book book = bookMapper.selectBookById(record.getBookId());
            if (book == null) {
                logger.error("图书不存在，ID: {}", record.getBookId());
                return false;
            }

            logger.debug("还书前：图书ID={}, 可借数量={}",
                    book.getId(), book.getAvailableCopies());

            book.setAvailableCopies(book.getAvailableCopies() + 1);

            // 如果图书原来是维护状态，还书后仍然保持维护状态
            if (!"MAINTENANCE".equals(book.getStatus())) {
                if (book.getAvailableCopies() > 0) {
                    book.setStatus("AVAILABLE");
                }
            }

            int updateBookResult = bookMapper.updateAvailableCopies(
                    record.getBookId(), book.getAvailableCopies());

            logger.debug("更新图书库存结果: {}, 新可借数量: {}",
                    updateBookResult, book.getAvailableCopies());

            logger.info("还书成功，记录ID: {}, 图书ID: {}",
                    recordId, record.getBookId());
            return updateBookResult > 0;

        } catch (Exception e) {
            logger.error("还书异常，记录ID: {}", recordId, e);
            throw new RuntimeException("归还图书失败", e);
        }
    }

    @Override
    public boolean renewBook(Integer recordId, Integer additionalDays) {
        try {
            logger.info("开始续借操作，记录ID: {}, 续借天数: {}", recordId, additionalDays);

            BorrowRecord record = borrowMapper.selectBorrowRecordById(recordId);
            if (record == null) {
                logger.error("借阅记录不存在，ID: {}", recordId);
                return false;
            }

            if (!"BORROWED".equals(record.getStatus())) {
                logger.warn("图书状态不是借阅中，无法续借，状态: {}", record.getStatus());
                return false;
            }

            // 检查图书状态 - 维护中的图书不能续借
            Book book = bookMapper.selectBookById(record.getBookId());
            if (book != null && "MAINTENANCE".equals(book.getStatus())) {
                logger.warn("图书维护中，不能续借，图书ID: {}", record.getBookId());
                // 可以抛出特定异常或在返回信息中说明
                throw new RuntimeException("图书正在维护中，无法续借");
            }

            // 检查是否已逾期
            if (checkOverdue(recordId)) {
                logger.warn("图书已逾期，无法续借，记录ID: {}", recordId);
                return false;
            }

            // 续借：延长应还日期
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(record.getDueDate());
            calendar.add(Calendar.DAY_OF_MONTH, additionalDays);
            record.setDueDate(calendar.getTime());

            int updateResult = borrowMapper.updateBorrowRecord(record);

            logger.info("续借成功，记录ID: {}, 新应还日期: {}, 更新结果: {}",
                    recordId, record.getDueDate(), updateResult);
            return updateResult > 0;
        } catch (Exception e) {
            logger.error("续借图书失败，记录ID: {}", recordId, e);
            throw new RuntimeException("该书正在维护中，续借图书失败", e);
        }
    }

    @Override
    @Transactional
    public boolean deleteBook(Integer id) {
        try {
            logger.info("开始删除图书，ID: {}", id);

            Book book = bookMapper.selectBookById(id);
            if (book == null) {
                logger.warn("图书不存在，ID: {}", id);
                return false;
            }

            // 检查是否有借阅记录
            int borrowRecordCount = borrowMapper.countBorrowRecordsByBookId(id);
            if (borrowRecordCount > 0) {
                logger.warn("图书存在借阅记录，不能删除，ID: {}", id);
                throw new RuntimeException("图书存在借阅记录，不能删除");
            }

            int result = bookMapper.deleteBook(id);
            logger.info("删除图书结果: {}, ID: {}", result, id);

            return result > 0;
        } catch (Exception e) {
            logger.error("删除图书失败，ID: {}", id, e);
            throw new RuntimeException("删除图书失败: " + e.getMessage(), e);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public BorrowRecord getBorrowRecordById(Integer id) {
        logger.debug("查询借阅记录，ID: {}", id);
        return borrowMapper.selectBorrowRecordById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BorrowRecord> getBorrowRecordsByUserId(Integer userId) {
        logger.debug("查询用户借阅记录，用户ID: {}", userId);
        return borrowMapper.selectBorrowRecordsByUserId(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BorrowRecord> getAllBorrowRecords() {
        logger.debug("查询所有借阅记录");
        return borrowMapper.selectAllBorrowRecords();
    }

    @Override
    @Transactional(readOnly = true)
    public List<BorrowRecord> getOverdueRecords() {
        logger.debug("查询逾期记录");
        return borrowMapper.selectOverdueRecords();
    }

    @Override
    @Transactional(readOnly = true)
    public boolean checkOverdue(Integer recordId) {
        logger.debug("检查是否逾期，记录ID: {}", recordId);
        BorrowRecord record = borrowMapper.selectBorrowRecordById(recordId);
        if (record == null || "RETURNED".equals(record.getStatus())) {
            return false;
        }

        Date now = new Date();
        boolean isOverdue = now.after(record.getDueDate());

        if (isOverdue) {
            logger.warn("记录已逾期，记录ID: {}, 应还日期: {}",
                    recordId, record.getDueDate());
        }

        return isOverdue;
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getBorrowStatistics() {
        logger.debug("获取借阅统计");
        Map<String, Object> statistics = new HashMap<>();

        try {
            // 获取所有借阅记录
            List<BorrowRecord> allRecords = borrowMapper.selectAllBorrowRecords();
            if (allRecords == null) {
                allRecords = new ArrayList<>();
            }

            int totalBorrows = allRecords.size();

            // 获取当前借阅中的记录
            List<BorrowRecord> currentBorrows = borrowMapper.selectBorrowingRecords();

            // ====== 关键修改：修复逾期记录查询 ======
            // 方法1：直接查询数据库中的OVERDUE状态记录
            int overdueCount = 0;
            Date now = new Date();

            // 统计所有借阅中且已过期的记录
            for (BorrowRecord record : allRecords) {
                if ("BORROWED".equals(record.getStatus()) && record.getDueDate() != null) {
                    if (now.after(record.getDueDate())) {
                        overdueCount++;
                        logger.debug("发现逾期记录，ID: {}, 应还日期: {}",
                                record.getId(), record.getDueDate());
                    }
                } else if ("OVERDUE".equals(record.getStatus())) {
                    // 如果记录状态已经是OVERDUE，直接计数
                    overdueCount++;
                }
            }

            // 方法2：同时使用Mapper方法查询（备份）
            List<BorrowRecord> overdueRecords = borrowMapper.selectOverdueRecords();
            logger.debug("Mapper查询逾期记录数量: {}",
                    overdueRecords != null ? overdueRecords.size() : 0);

            // 取较大值，确保不遗漏
            if (overdueRecords != null && overdueRecords.size() > overdueCount) {
                overdueCount = overdueRecords.size();
            }

            statistics.put("totalBorrows", totalBorrows);
            statistics.put("currentBorrows", currentBorrows != null ? currentBorrows.size() : 0);
            statistics.put("overdueCount", overdueCount);

            // 计算归还率
            int returnedCount = 0;
            for (BorrowRecord record : allRecords) {
                if ("RETURNED".equals(record.getStatus())) {
                    returnedCount++;
                }
            }

            double returnRate = totalBorrows > 0 ?
                    (double) returnedCount * 100 / totalBorrows : 0;
            statistics.put("returnRate", String.format("%.1f%%", returnRate));

            logger.debug("借阅统计：总数={}, 当前借阅={}, 逾期数={}, 归还率={}%",
                    totalBorrows,
                    currentBorrows != null ? currentBorrows.size() : 0,
                    overdueCount,
                    String.format("%.1f", returnRate));

        } catch (Exception e) {
            logger.error("获取借阅统计失败", e);
            // 提供默认值
            statistics.put("totalBorrows", 0);
            statistics.put("currentBorrows", 0);
            statistics.put("overdueCount", 0);
            statistics.put("returnRate", "0.0%");
        }

        return statistics;
    }

    @Override
    @Transactional(readOnly = true)
    public List<BorrowRecord> getBorrowRecordsByPage(int page, int pageSize) {
        logger.debug("分页查询借阅记录，页码={}, 页大小={}", page, pageSize);
        // 简化实现，实际项目应使用分页查询
        List<BorrowRecord> allRecords = getAllBorrowRecords();
        int start = (page - 1) * pageSize;
        int end = Math.min(start + pageSize, allRecords.size());
        return allRecords.subList(start, end);
    }

    @Override
    @Transactional(readOnly = true)
    public List<User> getUsersByPage(int page, int pageSize) {
        try {
            int start = (page - 1) * pageSize;
            return userMapper.selectUsersByPage(start, pageSize);
        } catch (Exception e) {
            logger.error("分页查询用户失败，page: {}, pageSize: {}", page, pageSize, e);
            return new ArrayList<>();
        }
    }

    // 检查图书是否可借（维护中状态检查）
    public boolean canBorrowBook(Integer bookId) {
        Book book = bookMapper.selectBookById(bookId);
        if (book == null) {
            return false;
        }
        return book.getAvailableCopies() > 0 && !"MAINTENANCE".equals(book.getStatus());
    }

    // 检查图书是否可以续借
    public boolean canRenewBook(Integer bookId) {
        Book book = bookMapper.selectBookById(bookId);
        if (book == null) {
            return false;
        }
        return !"MAINTENANCE".equals(book.getStatus());
    }
    private List<Map<String, Object>> completeMissingDays(List<Map<String, Object>> existingData, int days) {
        List<Map<String, Object>> completedData = new ArrayList<>();

        Calendar calendar = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        // 获取最近days天的所有日期
        for (int i = days - 1; i >= 0; i--) {
            calendar.setTime(new Date());
            calendar.add(Calendar.DAY_OF_MONTH, -i);
            String dateStr = sdf.format(calendar.getTime());

            // 查找这天是否有数据
            // Java 7兼容写法 - 手动遍历查找
            Map<String, Object> foundItem = null;
            for (Map<String, Object> item : existingData) {
                if (dateStr.equals(item.get("date"))) {
                    foundItem = item;
                    break;  // 找到就退出循环
                }
            }

            if (foundItem != null) {
                completedData.add(foundItem);
            } else {
                // 没有数据的天数，添加0值
                Map<String, Object> newItem = new HashMap<>();
                newItem.put("date", dateStr);
                newItem.put("count", 0);
                completedData.add(newItem);
            }
        }

        return completedData;
    }


    @Override
    public List<Map<String, Object>> getBorrowTrend(int days) {
        logger.info("开始获取最近{}天的借阅趋势数据", days);

        List<Map<String, Object>> result = new ArrayList<>();

        try {
            // 方法1：使用数据库直接查询（推荐）
            List<Map<String, Object>> dbTrend = borrowMapper.selectBorrowTrend(days);

            if (dbTrend != null && !dbTrend.isEmpty()) {
                // 处理数据库查询结果
                for (Map<String, Object> item : dbTrend) {
                    Map<String, Object> trendItem = new HashMap<>();

                    // 转换日期格式
                    Date date = (Date) item.get("date");
                    if (date != null) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        trendItem.put("date", sdf.format(date));
                    } else {
                        trendItem.put("date", item.get("date"));
                    }

                    // 借阅数量
                    Long count = (Long) item.get("count");
                    trendItem.put("count", count != null ? count.intValue() : 0);

                    result.add(trendItem);
                }

                // 如果数据不完整（有些天没有数据），补全
                result = completeMissingDays(result, days);

                logger.info("从数据库获取到{}天的借阅趋势数据", result.size());
            } else {
                // 如果数据库没有数据，生成模拟数据
                logger.warn("数据库中没有借阅趋势数据，生成模拟数据");
                result = generateMockTrendData(days);
            }

            // 按日期排序
            // Java 7兼容写法 - 使用Comparator匿名内部类
            java.util.Collections.sort(result, new java.util.Comparator<Map<String, Object>>() {
                @Override
                public int compare(Map<String, Object> a, Map<String, Object> b) {
                    String dateA = (String) a.get("date");
                    String dateB = (String) b.get("date");
                    return dateA.compareTo(dateB);
                }
            });

            // 调试输出
            logger.debug("借阅趋势数据:");
            for (Map<String, Object> item : result) {
                logger.debug("日期: {}, 借阅数量: {}", item.get("date"), item.get("count"));
            }

        } catch (Exception e) {
            logger.error("获取借阅趋势数据失败", e);
            // 出错时返回模拟数据
            result = generateMockTrendData(days);
        }

        return result;
    }
    private List<Map<String, Object>> generateMockTrendData(int days) {
        List<Map<String, Object>> mockData = new ArrayList<>();

        Calendar calendar = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        // 设置随机种子
        Random random = new Random(System.currentTimeMillis());

        // 生成最近days天的数据
        for (int i = days - 1; i >= 0; i--) {
            calendar.setTime(new Date());
            calendar.add(Calendar.DAY_OF_MONTH, -i);

            Map<String, Object> dayData = new HashMap<>();
            dayData.put("date", sdf.format(calendar.getTime()));

            // 模拟借阅数量（工作日多，周末少）
            int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
            int baseCount;

            if (dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY) {
                baseCount = 3; // 周末基础值
            } else {
                baseCount = 8; // 工作日基础值
            }

            // 添加随机波动
            int randomCount = baseCount + random.nextInt(5);
            dayData.put("count", randomCount);

            mockData.add(dayData);
        }

        logger.info("生成{}条模拟借阅趋势数据", mockData.size());
        return mockData;
    }
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getPopularBooks() {
        logger.info("获取热门图书排行");

        try {
            // 直接使用Mapper查询
            List<Map<String, Object>> popularBooks = borrowMapper.selectPopularBooks();

            if (popularBooks != null && !popularBooks.isEmpty()) {
                logger.info("获取到热门图书数据，数量: {}", popularBooks.size());

                // 格式化数据
                for (Map<String, Object> book : popularBooks) {
                    // 确保borrowCount是数字
                    Object borrowCount = book.get("borrowCount");
                    if (borrowCount instanceof Long) {
                        book.put("borrowCount", ((Long) borrowCount).intValue());
                    }

                    // 处理空值
                    if (book.get("title") == null) {
                        book.put("title", "未知图书");
                    }
                    if (book.get("author") == null) {
                        book.put("author", "未知作者");
                    }
                }

                return popularBooks;
            } else {
                logger.warn("热门图书数据为空，生成模拟数据");
                return generateMockPopularBooks();
            }

        } catch (Exception e) {
            logger.error("获取热门图书失败", e);
            return generateMockPopularBooks();
        }
    }

    // 备用模拟数据生成
    private List<Map<String, Object>> generateMockPopularBooks() {
        List<Map<String, Object>> mockBooks = new ArrayList<>();

        try {
            // 尝试获取所有图书
            List<Book> allBooks = bookMapper.selectAllBooks();

            if (allBooks != null && !allBooks.isEmpty()) {
                Random random = new Random();

                for (int i = 0; i < Math.min(5, allBooks.size()); i++) {
                    Book book = allBooks.get(i);
                    Map<String, Object> bookInfo = new HashMap<>();

                    bookInfo.put("bookId", book.getId());
                    bookInfo.put("title", book.getTitle());
                    bookInfo.put("author", book.getAuthor());
                    bookInfo.put("category", book.getCategory());
                    bookInfo.put("borrowCount", random.nextInt(20) + 1);

                    mockBooks.add(bookInfo);
                }
            }
        } catch (Exception e) {
            logger.error("生成模拟数据失败", e);
        }

        return mockBooks;
    }
}
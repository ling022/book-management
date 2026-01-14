package com.bookmanagement.service.impl;

import com.bookmanagement.dao.BookMapper;
import com.bookmanagement.dao.BorrowMapper;
import com.bookmanagement.entity.Book;
import com.bookmanagement.service.BookService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static java.util.ResourceBundle.clearCache;

@Service
@Transactional
public class BookServiceImpl implements BookService {
    private static final Logger logger = LoggerFactory.getLogger(BookServiceImpl.class);

    @Autowired
    private BookMapper bookMapper;
    @Autowired
    private BorrowMapper borrowMapper;

    // ====== 新增：简单内存缓存 ======
    private Map<String, Object> bookCache = new HashMap<>();
    private long lastCacheTime = 0;
    private static final long CACHE_TIMEOUT = 30000; // 30秒

    @Override
    public boolean addBook(Book book) {
        try {
            // 检查ISBN是否已存在
            Book existingBook = bookMapper.selectBookByIsbn(book.getIsbn());
            if (existingBook != null) {
                return false;
            }

            // 设置默认值
            if (book.getTotalCopies() == null) {
                book.setTotalCopies(1);
            }
            if (book.getAvailableCopies() == null) {
                book.setAvailableCopies(book.getTotalCopies());
            }
            if (book.getStatus() == null) {
                book.setStatus("AVAILABLE");
            }

            bookMapper.insertBook(book);
            clearCache();

            return true;
        } catch (Exception e) {
            throw new RuntimeException("添加图书失败", e);
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
            if (result > 0) {
                clearCache();
            }
            return result > 0;
        } catch (Exception e) {
            logger.error("删除图书失败，ID: {}", id, e);
            throw new RuntimeException("删除图书失败: " + e.getMessage(), e);
        }
    }

    private int checkBorrowRecords(Integer bookId) {
        // 这里需要查询借阅记录表
        // 如果BorrowMapper中有相关方法，调用它
        // 否则需要添加一个查询方法
        try {
            // 临时解决方案：直接返回0，允许删除
            // 实际项目中应该查询borrow_records表
            return 0;
        } catch (Exception e) {
            logger.error("检查借阅记录失败，图书ID: {}", bookId, e);
            return 0;
        }
    }

    @Override
    public boolean updateBook(Book book) {
        try {
            int result = bookMapper.updateBook(book);

            if (result > 0) {
                clearCache();
            }
            return result > 0;
        } catch (Exception e) {
            throw new RuntimeException("更新图书信息失败", e);
        }
    }

    @Override
    public Book getBookById(Integer id) {
        // 不使用Redis，直接查询数据库
        return bookMapper.selectBookById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Book> getAllBooks() {
        String cacheKey = "allBooks";
        long currentTime = System.currentTimeMillis();

        // 检查内存缓存是否有效
        if (bookCache.containsKey(cacheKey) &&
                (currentTime - lastCacheTime) < CACHE_TIMEOUT) {
            logger.debug("从内存缓存获取所有图书");
            return (List<Book>) bookCache.get(cacheKey);
        }

        // 缓存无效，查询数据库
        List<Book> books = bookMapper.selectAllBooks();

        // 更新内存缓存
        bookCache.put(cacheKey, books);
        lastCacheTime = currentTime;
        logger.debug("更新图书内存缓存，数量: {}", books.size());

        return books;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Book> searchBooks(String keyword, String category) {
        return bookMapper.selectBooksByCondition(keyword, category);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Book> getBooksByPage(int page, int pageSize) {
        int start = (page - 1) * pageSize;
        return bookMapper.selectBooksByPage(start, pageSize);
    }

    @Override
    @Transactional(readOnly = true)
    public int getBookCount() {
        String cacheKey = "bookCount";
        long currentTime = System.currentTimeMillis();

        // 检查内存缓存
        if (bookCache.containsKey(cacheKey) &&
                (currentTime - lastCacheTime) < CACHE_TIMEOUT) {
            return (int) bookCache.get(cacheKey);
        }

        int count = bookMapper.countBooks();
        bookCache.put(cacheKey, count);
        lastCacheTime = currentTime;

        return count;
    }

    private void clearCache() {
        bookCache.clear();
        lastCacheTime = 0;
        logger.debug("清除图书内存缓存");
    }

    @Override
    public Book getBookByIsbn(String isbn) {
        return bookMapper.selectBookByIsbn(isbn);
    }

    @Override
    public Map<String, Object> getBookStatistics() {
        Map<String, Object> result = new HashMap<>();
        try {
            List<Book> books = bookMapper.selectAllBooks();

            // 统计分类
            Map<String, Integer> categoryStats = new HashMap<>();
            int totalBooks = 0;
            int availableBooks = 0;

            for (Book book : books) {
                totalBooks += book.getTotalCopies();
                availableBooks += book.getAvailableCopies();

                String category = book.getCategory();
                if (category == null || category.trim().isEmpty()) {
                    category = "未分类";
                }
                Integer count = categoryStats.get(category);
                categoryStats.put(category, (count != null ? count : 0) + 1);}

            result.put("totalBooks", books.size());
            result.put("totalCopies", totalBooks);
            result.put("availableCopies", availableBooks);
            result.put("borrowedCopies", totalBooks - availableBooks);
            result.put("categoryStats", categoryStats);

        } catch (Exception e) {
            logger.error("获取图书统计信息失败", e);
            result.put("error", "获取统计信息失败：" + e.getMessage());
        }
        return result;
    }
}
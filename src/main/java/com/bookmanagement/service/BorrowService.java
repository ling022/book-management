package com.bookmanagement.service;

import com.bookmanagement.entity.BorrowRecord;
import com.bookmanagement.entity.User;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;
import java.util.Map;

public interface BorrowService {
    // 借阅图书
    boolean borrowBook(Integer userId, Integer bookId, Integer days);

    // 归还图书
    boolean returnBook(Integer recordId);

    // 续借图书
    boolean renewBook(Integer recordId, Integer additionalDays);

    boolean deleteBook(Integer id);

    // 获取借阅记录
    BorrowRecord getBorrowRecordById(Integer id);

    // 获取用户的所有借阅记录
    List<BorrowRecord> getBorrowRecordsByUserId(Integer userId);

    // 获取所有借阅记录
    List<BorrowRecord> getAllBorrowRecords();

    // 获取逾期记录
    List<BorrowRecord> getOverdueRecords();

    // 检查是否逾期
    boolean checkOverdue(Integer recordId);

    // 获取借阅统计
    Map<String, Object> getBorrowStatistics();

    // 分页查询借阅记录
    List<BorrowRecord> getBorrowRecordsByPage(int page, int pageSize);
    List<Map<String, Object>> getBorrowTrend(int days);

    @Transactional(readOnly = true)
    List<User> getUsersByPage(int page, int pageSize);
    // 获取热门图书排行
    List<Map<String, Object>> getPopularBooks();
}

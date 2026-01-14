package com.bookmanagement.dao;

import com.bookmanagement.entity.BorrowRecord;
import org.apache.ibatis.annotations.Param;

import java.util.Date;
import java.util.List;
import java.util.Map;

public interface BorrowMapper {
    // 添加借阅记录
    int insertBorrowRecord(BorrowRecord record);

    // 更新借阅记录
    int updateBorrowRecord(BorrowRecord record);

    // 根据ID查询借阅记录
    BorrowRecord selectBorrowRecordById(Integer id);

    // 根据用户ID查询借阅记录
    List<BorrowRecord> selectBorrowRecordsByUserId(Integer userId);

    // 查询所有借阅记录（多表关联查询）
    List<BorrowRecord> selectAllBorrowRecords();

    // 查询未归还的借阅记录
    List<BorrowRecord> selectBorrowingRecords();

    // 查询逾期记录
    List<BorrowRecord> selectOverdueRecords();

    // 还书操作
    int returnBook(@Param("id") Integer id,
                   @Param("returnDate") Date returnDate);
    // 统计图书的借阅记录数量
    int countBorrowRecordsByBookId(Integer bookId);
    // 查询借阅记录总数
    int countBorrowRecords();

    // 查询用户的借阅数量
    int countUserBorrowRecords(Integer userId);

    // 检查是否已借阅该书
    BorrowRecord checkBorrowed(@Param("userId") Integer userId,
                               @Param("bookId") Integer bookId);
    List<Map<String, Object>> selectBorrowTrend(@Param("days") int days);

    // 按日期范围查询借阅数量
    List<Map<String, Object>> selectBorrowCountByDateRange(
            @Param("startDate") Date startDate,
            @Param("endDate") Date endDate);
    // 获取热门图书排行
    List<Map<String, Object>> selectPopularBooks();
}
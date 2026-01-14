package com.bookmanagement.dao;

import com.bookmanagement.entity.Book;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface BookMapper {
    // 添加图书
    int insertBook(Book book);

    // 删除图书
    int deleteBook(Integer id);

    // 更新图书信息
    int updateBook(Book book);

    // 根据ID查询图书
    Book selectBookById(Integer id);

    // 查询所有图书
    List<Book> selectAllBooks();

    // 根据条件查询图书
    List<Book> selectBooksByCondition(@Param("keyword") String keyword,
                                      @Param("category") String category);

    // 根据ISBN查询图书
    Book selectBookByIsbn(String isbn);

    // 统计图书的借阅记录数量
    int countBorrowRecordsByBookId(Integer bookId);
    // 查询图书总数
    int countBooks();

    // 更新图书库存
    int updateAvailableCopies(@Param("id") Integer id,
                              @Param("availableCopies") Integer availableCopies);

    // 分页查询图书
    List<Book> selectBooksByPage(@Param("start") int start,
                                 @Param("pageSize") int pageSize);
}
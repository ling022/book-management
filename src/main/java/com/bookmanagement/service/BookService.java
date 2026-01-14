package com.bookmanagement.service;

import com.bookmanagement.entity.Book;

import java.util.List;
import java.util.Map;

public interface BookService {
    // 添加图书
    boolean addBook(Book book);

    // 删除图书
    boolean deleteBook(Integer id);

    // 更新图书信息
    boolean updateBook(Book book);

    // 根据ID查询图书
    Book getBookById(Integer id);

    // 查询所有图书
    List<Book> getAllBooks();

    // 搜索图书
    List<Book> searchBooks(String keyword, String category);

    // 分页查询图书
    List<Book> getBooksByPage(int page, int pageSize);

    // 获取图书总数
    int getBookCount();
    Book getBookByIsbn(String isbn);


    Map<String, Object> getBookStatistics();
}
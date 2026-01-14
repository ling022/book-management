package com.bookmanagement.service;

import com.bookmanagement.entity.Book;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Map;

public interface FileUploadService {
    /**
     * 上传图书封面图片
     */
    Map<String, Object> uploadBookImage(MultipartFile file, Integer bookId,
                                        HttpServletRequest request, HttpSession session);

    /**
     * 删除图书封面图片
     */
    Map<String, Object> deleteBookImage(Integer bookId,
                                        HttpServletRequest request, HttpSession session);
}
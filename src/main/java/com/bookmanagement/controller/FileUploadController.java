package com.bookmanagement.controller;

import com.bookmanagement.entity.Book;
import com.bookmanagement.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Controller
@RequestMapping("/upload")
public class FileUploadController {

    @Autowired
    private BookService bookService;

    @PostMapping("/bookImage")
    @ResponseBody
    public Map<String, Object> uploadBookImage(@RequestParam("imageFile") MultipartFile file,
                                               @RequestParam("bookId") Integer bookId,
                                               HttpServletRequest request,
                                               HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        System.out.println("=== 开始处理文件上传 ===");
        System.out.println("bookId: " + bookId);
        System.out.println("文件名: " + file.getOriginalFilename());
        System.out.println("文件大小: " + file.getSize());
        System.out.println("Context Path: " + request.getContextPath());

        try {
            // 1. 基本验证
            if (file.isEmpty()) {
                result.put("success", false);
                result.put("message", "请选择文件");
                return result;
            }

            if (bookId == null) {
                result.put("success", false);
                result.put("message", "图书ID不能为空");
                return result;
            }

            // 2. 权限检查
            String role = (String) session.getAttribute("role");
            if (!"ADMIN".equals(role)) {
                result.put("success", false);
                result.put("message", "权限不足");
                return result;
            }

            // 3. 获取图书
            Book book = bookService.getBookById(bookId);
            if (book == null) {
                result.put("success", false);
                result.put("message", "图书不存在");
                return result;
            }

            // 4. ====== 关键修改：保存到项目目录 ======
            // 获取项目的真实路径（webapp目录）
            String webappPath = request.getServletContext().getRealPath("/");
            System.out.println("Web应用根路径: " + webappPath);

            // 构建上传目录路径：webapp/uploads/book_images/
            String uploadDirPath = webappPath + "uploads/book_images/";
            File uploadDir = new File(uploadDirPath);

            // 如果目录不存在，创建它
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                System.out.println("创建目录: " + uploadDirPath + ", 成功: " + created);
            }

            // 检查目录权限
            System.out.println("目录可写: " + uploadDir.canWrite());
            System.out.println("目录绝对路径: " + uploadDir.getAbsolutePath());

            // 5. 生成文件名
            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            // 生成唯一文件名（避免重名）
            String newFilename = System.currentTimeMillis() + "_" +
                    UUID.randomUUID().toString().substring(0, 8) +
                    fileExtension;

            // 完整保存路径
            String fullFilePath = uploadDirPath + newFilename;
            File destFile = new File(fullFilePath);

            System.out.println("文件保存路径: " + fullFilePath);

            // 6. 保存文件
            file.transferTo(destFile);
            System.out.println("文件保存成功，大小: " + destFile.length() + " bytes");
            System.out.println("文件存在: " + destFile.exists());

            // 7. ====== 关键修改：使用正确的相对路径 ======
            // 相对路径（相对于webapp根目录）
            String relativePath = "/uploads/book_images/" + newFilename;
            System.out.println("相对路径（存数据库）: " + relativePath);

            // 8. 更新数据库
            book.setImagePath(relativePath);
            boolean updated = bookService.updateBook(book);
            System.out.println("数据库更新结果: " + updated);

            // 9. 返回成功信息
            result.put("success", true);
            result.put("message", "上传成功");
            result.put("imageUrl", relativePath); // 返回相对路径

            System.out.println("=== 文件上传完成 ===");

        } catch (IOException e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "文件保存失败: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "上传失败: " + e.getClass().getName() + ": " + e.getMessage());
        }

        return result;
    }

    @GetMapping("/deleteImage")
    @ResponseBody
    public Map<String, Object> deleteBookImage(@RequestParam Integer bookId,
                                               HttpServletRequest request,
                                               HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        System.out.println("=== 开始删除图片 ===");
        System.out.println("bookId: " + bookId);

        try {
            // 权限检查
            String role = (String) session.getAttribute("role");
            if (!"ADMIN".equals(role)) {
                result.put("success", false);
                result.put("message", "权限不足！");
                return result;
            }

            // 获取图书信息
            Book book = bookService.getBookById(bookId);
            if (book == null) {
                result.put("success", false);
                result.put("message", "图书不存在");
                return result;
            }

            // 检查是否有图片
            if (book.getImagePath() == null || book.getImagePath().trim().isEmpty()) {
                result.put("success", false);
                result.put("message", "图书没有封面图片");
                return result;
            }

            // 获取图片路径
            String imagePath = book.getImagePath();
            System.out.println("数据库中的图片路径: " + imagePath);

            // ====== 关键修改：从项目目录删除文件 ======
            // 获取项目根路径
            String webappPath = request.getServletContext().getRealPath("/");
            // 构建完整路径（去掉开头的斜杠）
            String relativePath = imagePath.startsWith("/") ? imagePath.substring(1) : imagePath;
            String fullPath = webappPath + relativePath;

            File imageFile = new File(fullPath);
            System.out.println("要删除的文件路径: " + fullPath);
            System.out.println("文件是否存在: " + imageFile.exists());

            // 删除物理文件
            if (imageFile.exists()) {
                boolean deleted = imageFile.delete();
                System.out.println("文件删除结果: " + deleted);
                if (!deleted) {
                    result.put("success", false);
                    result.put("message", "文件删除失败，可能被占用或无权限");
                    return result;
                }
            } else {
                System.out.println("警告：物理文件不存在，可能已被删除");
            }

            // 更新数据库
            book.setImagePath(null);
            boolean updated = bookService.updateBook(book);
            System.out.println("数据库更新结果: " + updated);

            result.put("success", true);
            result.put("message", "图片删除成功");

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "删除失败：" + e.getMessage());
        }

        return result;
    }
}
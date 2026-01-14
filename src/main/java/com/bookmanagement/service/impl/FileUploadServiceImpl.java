package com.bookmanagement.service.impl;

import com.bookmanagement.dao.BookMapper;
import com.bookmanagement.entity.Book;
import com.bookmanagement.service.BookService;
import com.bookmanagement.service.FileUploadService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@Transactional
public class FileUploadServiceImpl implements FileUploadService {

    private static final Logger logger = LoggerFactory.getLogger(FileUploadServiceImpl.class);

    @Autowired
    private BookService bookService;

    @Override
    public Map<String, Object> uploadBookImage(MultipartFile file, Integer bookId,
                                               HttpServletRequest request, HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        logger.info("=== 开始处理文件上传 ===");
        logger.info("bookId: {}", bookId);
        logger.info("文件名: {}", file.getOriginalFilename());
        logger.info("文件大小: {}", file.getSize());

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

            // 4. 获取项目真实路径
            //String webappPath = request.getServletContext().getRealPath("/");
            /*logger.info("Web应用根路径: {}", webappPath);

            // 构建上传目录路径：webapp/uploads/book_images/
            String uploadDirPath = webappPath + "uploads/book_images/";
            File uploadDir = new File(uploadDirPath);

            // 如果目录不存在，创建它
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                logger.info("创建目录: {}, 成功: {}", uploadDirPath, created);
            }*/



            // Java 7云部署专用 - 文件上传路径处理
            String uploadDirPath;

            // 先检查是否是云环境（Railway）
            String railwayEnv = System.getenv("RAILWAY_ENVIRONMENT");
            String railwayAppName = System.getenv("RAILWAY_APPLICATION_NAME");

            if (railwayEnv != null || railwayAppName != null) {
                // 情况1：在Railway云环境 - 使用临时目录
                logger.info("检测到云环境，使用临时目录");

                // Java 7获取临时目录的方法
                String tempDir = System.getProperty("java.io.tmpdir");
                logger.info("系统临时目录: {}", tempDir);

                // 构建上传路径
                uploadDirPath = tempDir + "uploads/book_images/";

            } else {
                // 情况2：本地环境 - 使用项目目录
                try {
                    String webappPath = request.getServletContext().getRealPath("/");
                    logger.info("本地环境，项目路径: {}", webappPath);
                    uploadDirPath = webappPath + "uploads/book_images/";
                } catch (Exception e) {
                    // 如果获取失败，也用临时目录
                    logger.warn("获取项目路径失败，使用临时目录");
                    uploadDirPath = System.getProperty("java.io.tmpdir") + "uploads/book_images/";
                }
            }

            logger.info("最终上传目录: {}", uploadDirPath);

// 创建目录
            File uploadDir = new File(uploadDirPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                logger.info("创建目录: {}, 成功: {}", uploadDirPath, created);

                // 检查目录是否可写（Java 7写法）
                if (uploadDir.exists()) {
                    boolean canWrite = uploadDir.canWrite();
                    logger.info("目录可写: {}", canWrite);
                    if (!canWrite) {
                        logger.error("目录不可写，文件上传将失败！");
                    }
                }
            }


            // 5. 生成文件名
            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            // 生成唯一文件名
            String newFilename = System.currentTimeMillis() + "_" +
                    UUID.randomUUID().toString().substring(0, 8) +
                    fileExtension;

            // 完整保存路径
            String fullFilePath = uploadDirPath + newFilename;
            File destFile = new File(fullFilePath);

            logger.info("文件保存路径: {}", fullFilePath);

            // 6. 保存文件
            file.transferTo(destFile);
            logger.info("文件保存成功，大小: {} bytes", destFile.length());

            // 7. 使用正确的相对路径
            String relativePath = "/uploads/book_images/" + newFilename;
            logger.info("相对路径（存数据库）: {}", relativePath);

            // 8. 更新数据库
            book.setImagePath(relativePath);
            boolean updated = bookService.updateBook(book);
            logger.info("数据库更新结果: {}", updated);

            // 9. 返回成功信息
            result.put("success", true);
            result.put("message", "上传成功");
            result.put("imageUrl", relativePath);

            logger.info("=== 文件上传完成 ===");

        } catch (IOException e) {
            logger.error("文件保存失败", e);
            result.put("success", false);
            result.put("message", "文件保存失败: " + e.getMessage());
        } catch (Exception e) {
            logger.error("上传失败", e);
            result.put("success", false);
            result.put("message", "上传失败: " + e.getClass().getName() + ": " + e.getMessage());
        }

        return result;
    }

    @Override
    public Map<String, Object> deleteBookImage(Integer bookId,
                                               HttpServletRequest request, HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        logger.info("=== 开始删除图片 ===");
        logger.info("bookId: {}", bookId);

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
            logger.info("数据库中的图片路径: {}", imagePath);

            // 从项目目录删除文件
            //String webappPath = request.getServletContext().getRealPath("/");
// Java 7云环境判断
            String railwayEnv = System.getenv("RAILWAY_ENVIRONMENT");
            String webappPath;

            if (railwayEnv != null) {
                // 云环境用临时目录
                webappPath = System.getProperty("java.io.tmpdir");
                // 确保路径正确（Java 7需要处理路径分隔符）
                if (!webappPath.endsWith(File.separator)) {
                    webappPath = webappPath + File.separator;
                }
            } else {
                // 本地环境
                webappPath = request.getServletContext().getRealPath("/");
            }
            logger.info("删除文件 - 根路径: {}", webappPath);
            // 构建完整路径（去掉开头的斜杠）
            String relativePath = imagePath.startsWith("/") ? imagePath.substring(1) : imagePath;
            String fullPath = webappPath + relativePath;

            File imageFile = new File(fullPath);
            logger.info("要删除的文件路径: {}", fullPath);
            logger.info("文件是否存在: {}", imageFile.exists());

            // 删除物理文件
            if (imageFile.exists()) {
                boolean deleted = imageFile.delete();
                logger.info("文件删除结果: {}", deleted);
                if (!deleted) {
                    result.put("success", false);
                    result.put("message", "文件删除失败，可能被占用或无权限");
                    return result;
                }
            } else {
                logger.warn("警告：物理文件不存在，可能已被删除");
            }

            // 更新数据库
            book.setImagePath(null);
            boolean updated = bookService.updateBook(book);
            logger.info("数据库更新结果: {}", updated);

            result.put("success", true);
            result.put("message", "图片删除成功");

        } catch (Exception e) {
            logger.error("删除失败", e);
            result.put("success", false);
            result.put("message", "删除失败：" + e.getMessage());
        }

        return result;
    }
}

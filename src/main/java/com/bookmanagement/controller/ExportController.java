package com.bookmanagement.controller;

import com.bookmanagement.entity.Book;
import com.bookmanagement.entity.BorrowRecord;
import com.bookmanagement.entity.User;
import com.bookmanagement.service.BookService;
import com.bookmanagement.service.BorrowService;
import com.bookmanagement.service.UserService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Controller
@RequestMapping("/export")
public class ExportController {

    @Autowired
    private UserService userService;

    @Autowired
    private BookService bookService;

    @Autowired
    private BorrowService borrowService;

    // 导出用户信息
    @GetMapping("/users")
    public void exportUsers(HttpServletRequest request,
                            HttpServletResponse response,
                            HttpSession session) throws IOException {

        // 权限检查
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            response.sendError(403, "权限不足");
            return;
        }

        List<User> users = userService.getAllUsers();

        // 创建Excel工作簿
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("用户信息");

        // 创建表头样式
        CellStyle headerStyle = workbook.createCellStyle();
        headerStyle.setFillForegroundColor(IndexedColors.LIGHT_BLUE.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        headerStyle.setAlignment(HorizontalAlignment.CENTER);
        headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerFont.setFontHeightInPoints((short) 12);
        headerStyle.setFont(headerFont);

        // 创建数据行样式
        CellStyle dataStyle = workbook.createCellStyle();
        dataStyle.setAlignment(HorizontalAlignment.LEFT);
        dataStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        // 创建表头
        String[] headers = {"用户ID", "用户名", "角色", "邮箱", "电话", "注册时间"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
            sheet.autoSizeColumn(i);
        }

        // 填充数据
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        int rowNum = 1;
        for (User user : users) {
            Row row = sheet.createRow(rowNum++);

            row.createCell(0).setCellValue(user.getId());
            row.createCell(1).setCellValue(user.getUsername());
            row.createCell(2).setCellValue("ADMIN".equals(user.getRole()) ? "管理员" : "普通用户");
            row.createCell(3).setCellValue(user.getEmail() != null ? user.getEmail() : "");
            row.createCell(4).setCellValue(user.getPhone() != null ? user.getPhone() : "");
            row.createCell(5).setCellValue(user.getCreatedTime() != null ?
                    sdf.format(user.getCreatedTime()) : "");

            // 设置数据行样式
            for (int i = 0; i < headers.length; i++) {
                row.getCell(i).setCellStyle(dataStyle);
            }
        }

        // 设置响应头
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String filename = "用户信息_" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + ".xlsx";
        response.setHeader("Content-Disposition",
                "attachment; filename=" + URLEncoder.encode(filename, "UTF-8"));

        // 写入响应流
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    // 导出借阅信息
    @GetMapping("/borrows")
    public void exportBorrows(HttpServletRequest request,
                              HttpServletResponse response,
                              HttpSession session) throws IOException {

        // 权限检查
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            response.sendError(403, "权限不足");
            return;
        }

        List<BorrowRecord> records = borrowService.getAllBorrowRecords();

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("借阅信息");

        // 样式设置（同上）
        CellStyle headerStyle = workbook.createCellStyle();
        headerStyle.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        headerStyle.setAlignment(HorizontalAlignment.CENTER);
        headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerFont.setFontHeightInPoints((short) 12);
        headerStyle.setFont(headerFont);

        CellStyle dataStyle = workbook.createCellStyle();
        dataStyle.setAlignment(HorizontalAlignment.LEFT);
        dataStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        // 创建表头
        String[] headers = {"记录ID", "用户", "图书", "借阅日期", "应还日期", "归还日期", "状态"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
            sheet.autoSizeColumn(i);
        }

        // 填充数据
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        int rowNum = 1;
        for (BorrowRecord record : records) {
            Row row = sheet.createRow(rowNum++);

            row.createCell(0).setCellValue(record.getId());
            row.createCell(1).setCellValue(record.getUser() != null ? record.getUser().getUsername() : "未知用户");
            row.createCell(2).setCellValue(record.getBook() != null ? record.getBook().getTitle() : "未知图书");
            row.createCell(3).setCellValue(record.getBorrowDate() != null ?
                    sdf.format(record.getBorrowDate()) : "");
            row.createCell(4).setCellValue(record.getDueDate() != null ?
                    sdf.format(record.getDueDate()) : "");
            row.createCell(5).setCellValue(record.getReturnDate() != null ?
                    sdf.format(record.getReturnDate()) : "未归还");

            String status = "";
            switch (record.getStatus()) {
                case "BORROWED": status = "借阅中"; break;
                case "RETURNED": status = "已归还"; break;
                case "OVERDUE": status = "已逾期"; break;
                default: status = record.getStatus();
            }
            row.createCell(6).setCellValue(status);

            // 设置数据行样式
            for (int i = 0; i < headers.length; i++) {
                row.getCell(i).setCellStyle(dataStyle);
            }
        }

        // 设置响应头
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String filename = "借阅信息_" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + ".xlsx";
        response.setHeader("Content-Disposition",
                "attachment; filename=" + URLEncoder.encode(filename, "UTF-8"));

        workbook.write(response.getOutputStream());
        workbook.close();
    }

    // 导出图书信息
    @GetMapping("/books")
    public void exportBooks(HttpServletRequest request,
                            HttpServletResponse response,
                            HttpSession session) throws IOException {

        // 权限检查
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            response.sendError(403, "权限不足");
            return;
        }

        List<Book> books = bookService.getAllBooks();

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("图书信息");

        // 样式设置
        CellStyle headerStyle = workbook.createCellStyle();
        headerStyle.setFillForegroundColor(IndexedColors.LIGHT_ORANGE.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        headerStyle.setAlignment(HorizontalAlignment.CENTER);
        headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerFont.setFontHeightInPoints((short) 12);
        headerStyle.setFont(headerFont);

        CellStyle dataStyle = workbook.createCellStyle();
        dataStyle.setAlignment(HorizontalAlignment.LEFT);
        dataStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        // 创建表头
        String[] headers = {"图书ID", "书名", "作者", "ISBN", "出版社", "分类",
                "总数量", "可借数量", "状态", "添加时间"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
            sheet.autoSizeColumn(i);
        }

        // 填充数据
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        int rowNum = 1;
        for (Book book : books) {
            Row row = sheet.createRow(rowNum++);

            row.createCell(0).setCellValue(book.getId());
            row.createCell(1).setCellValue(book.getTitle());
            row.createCell(2).setCellValue(book.getAuthor());
            row.createCell(3).setCellValue(book.getIsbn());
            row.createCell(4).setCellValue(book.getPublisher() != null ? book.getPublisher() : "");
            row.createCell(5).setCellValue(book.getCategory() != null ? book.getCategory() : "");
            row.createCell(6).setCellValue(book.getTotalCopies());
            row.createCell(7).setCellValue(book.getAvailableCopies());

            String status = "";
            switch (book.getStatus()) {
                case "AVAILABLE": status = "可借"; break;
                case "BORROWED": status = "已借出"; break;
                case "MAINTENANCE": status = "维护中"; break;
                default: status = book.getStatus();
            }
            row.createCell(8).setCellValue(status);
            row.createCell(9).setCellValue(book.getCreatedTime() != null ?
                    sdf.format(book.getCreatedTime()) : "");

            // 设置数据行样式
            for (int i = 0; i < headers.length; i++) {
                row.getCell(i).setCellStyle(dataStyle);
            }
        }

        // 设置响应头
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String filename = "图书信息_" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + ".xlsx";
        response.setHeader("Content-Disposition",
                "attachment; filename=" + URLEncoder.encode(filename, "UTF-8"));

        workbook.write(response.getOutputStream());
        workbook.close();
    }
}
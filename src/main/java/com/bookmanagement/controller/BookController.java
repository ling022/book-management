package com.bookmanagement.controller;

import com.bookmanagement.entity.Book;
import com.bookmanagement.service.BookService;
import com.bookmanagement.service.BorrowService;
import com.bookmanagement.service.FileUploadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.text.SimpleDateFormat;
import java.util.*;

@Controller
@RequestMapping("/book")
public class BookController {

    private static final int PAGE_SIZE = 9; // 改为9个每页

    @Autowired
    private BookService bookService;

    @Autowired
    private FileUploadService fileUploadService;

    @Autowired
    private BorrowService borrowService;

    @PostMapping("/edit")
    public String updateBook(@ModelAttribute Book book,
                             @RequestParam(value = "publishDateStr", required = false) String publishDateStr,
                             HttpSession session,
                             RedirectAttributes redirectAttributes,
                             HttpServletRequest request) {
        // 权限检查
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            redirectAttributes.addFlashAttribute("errorMessage", "权限不足！只有管理员可以编辑图书。");
            return "redirect:/book/list";
        }
        try {
            // 处理日期转换
            if (publishDateStr != null && !publishDateStr.trim().isEmpty()) {
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    Date publishDate = sdf.parse(publishDateStr);
                    book.setPublishDate(publishDate);
                } catch (Exception e) {
                    redirectAttributes.addFlashAttribute("errorMessage", "日期格式错误，请使用yyyy-MM-dd格式");
                    return "redirect:/book/edit/" + book.getId();
                }
            }

            // 确保图片路径不被清空
            Book existingBook = bookService.getBookById(book.getId());
            if (existingBook != null) {
                // 情况1：如果表单中的图片路径为空字符串，说明要删除图片
                if (book.getImagePath() != null && book.getImagePath().equals("")) {
                    book.setImagePath(null);
                }
                // 情况2：如果表单中没有图片路径字段（为null），保持原图
                else if (book.getImagePath() == null) {
                    book.setImagePath(existingBook.getImagePath());
                }
            }

            boolean success = bookService.updateBook(book);
            if (success) {
                redirectAttributes.addFlashAttribute("successMessage", "图书更新成功！");
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "图书更新失败！");
            }
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "更新失败：" + e.getMessage());
        }
        return "redirect:/book/list";
    }

    // 显示所有图书
    @GetMapping("/list")
    public String listBooks(Model model,
                            @RequestParam(value = "page", defaultValue = "1") int page,
                            @RequestParam(value = "keyword", required = false) String keyword,
                            @RequestParam(value = "category", required = false) String category,
                            HttpServletRequest request) {

        int pageSize = PAGE_SIZE;

        List<Book> books;
        int totalBooks;

        if ((keyword != null && !keyword.trim().isEmpty()) ||
                (category != null && !category.trim().isEmpty())) {
            // 搜索功能
            books = bookService.searchBooks(keyword, category);
            totalBooks = books.size();
        } else {
            // 分页查询
            books = bookService.getBooksByPage(page, pageSize);
            totalBooks = bookService.getBookCount();
        }

        int totalPages = (int) Math.ceil((double) totalBooks / pageSize);

        model.addAttribute("books", books);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("keyword", keyword);
        model.addAttribute("category", category);
        model.addAttribute("pageSize", pageSize);

        return "book/list";
    }

    // 显示添加图书页面
    @GetMapping("/add")
    public String showAddForm(Model model,
                              HttpSession session,
                              @RequestParam(value = "ajax", defaultValue = "false") boolean ajaxRequest) {
        // 权限检查 - 只有管理员可以添加图书
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            model.addAttribute("errorMessage", "权限不足！只有管理员可以添加图书。");
            return "redirect:/book/list";
        }

        model.addAttribute("book", new Book());

        if (ajaxRequest) {
            return "book/add :: form";
        }
        return "book/add";
    }

    // 处理添加图书请求 - 改为普通表单提交
    @PostMapping("/add")
    public String addBook(@ModelAttribute Book book,
                          @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                          HttpSession session,
                          RedirectAttributes redirectAttributes,
                          HttpServletRequest request) {

        // 权限检查
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            redirectAttributes.addFlashAttribute("errorMessage", "权限不足！只有管理员可以添加图书。");
            return "redirect:/book/list";
        }

        try {
            // 保存图书基本信息
            boolean success = bookService.addBook(book);

            if (success) {
                // ====== 新增：处理图片上传 ======
                if (imageFile != null && !imageFile.isEmpty()) {
                    try {
                        // 获取最新添加的图书ID
                        Book latestBook = bookService.getBookByIsbn(book.getIsbn());
                        if (latestBook != null) {
                            // 调用文件上传服务
                            Map<String, Object> uploadResult = fileUploadService.uploadBookImage(
                                    imageFile, latestBook.getId(), request, session);


                            if (uploadResult != null && !(Boolean) uploadResult.get("success")) {
                                redirectAttributes.addFlashAttribute("warningMessage",
                                        "图书添加成功，但封面上传失败：" + uploadResult.get("message"));
                                 } else if (uploadResult != null && (Boolean) uploadResult.get("success")) {
                                System.out.println("图片上传成功，路径: " + uploadResult.get("imageUrl"));
                            }
                        } else {
                            System.out.println("无法获取新添加的图书信息");
                        }
                    } catch (Exception e) {
                        // 图片上传失败不影响主流程
                        e.printStackTrace();
                        redirectAttributes.addFlashAttribute("warningMessage",
                                "图书添加成功，但封面上传失败：" + e.getMessage());
                        System.out.println("图片上传异常: " + e.getMessage());
                    }
                } else {
                    System.out.println("没有上传图片文件");
                }

                redirectAttributes.addFlashAttribute("successMessage", "图书添加成功！");
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "ISBN已存在，添加失败！");
            }
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "添加失败：" + e.getMessage());
        }
        return "redirect:/book/list";
    }

    // 显示编辑图书页面
    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Integer id,
                               Model model,
                               HttpSession session,
                               RedirectAttributes redirectAttributes,
                               @RequestParam(value = "ajax", defaultValue = "false") boolean ajaxRequest) {
        // 权限检查
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            redirectAttributes.addFlashAttribute("errorMessage", "权限不足！只有管理员可以编辑图书。");
            return "redirect:/book/detail/" + id;
        }

        Book book = bookService.getBookById(id);
        if (book == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "图书不存在！");
            return "redirect:/book/list";
        }
        model.addAttribute("book", book);
        if (ajaxRequest) {
            return "book/edit :: form";
        }
        return "book/edit";
    }

    // 删除图书
    @GetMapping("/delete/{id}")
    @ResponseBody
    public Map<String, Object> deleteBook(@PathVariable Integer id,
                                          HttpSession session,
                                          RedirectAttributes redirectAttributes) {
        Map<String, Object> result = new HashMap<>();

        // 权限检查
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            result.put("success", false);
            result.put("errorMessage", "权限不足！只有管理员可以删除图书。");
            return result;
        }

        try {
            boolean success = bookService.deleteBook(id);
            if (success) {
                result.put("success", true);
                result.put("successMessage", "图书删除成功！");
            } else {
                result.put("success", false);
                result.put("errorMessage", "图书删除失败！");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("errorMessage", "删除失败：" + e.getMessage());
        }
        return result;
    }

    // 查看图书详情
    @GetMapping("/detail/{id}")
    public String viewBookDetail(@PathVariable Integer id,
                                 Model model,
                                 HttpSession session,
                                 @RequestParam(value = "ajax", defaultValue = "false") boolean ajaxRequest) {
        Book book = bookService.getBookById(id);
        if (book == null) {
            model.addAttribute("errorMessage", "图书不存在！");
            return "redirect:/book/list";
        }
        model.addAttribute("book", book);

        // 传递权限信息给页面
        String role = (String) session.getAttribute("role");
        model.addAttribute("isAdmin", "ADMIN".equals(role));
        model.addAttribute("isUser", "USER".equals(role));
        if (ajaxRequest) {
            return "book/detail :: content";
        }
        return "book/detail";
    }

    // AJAX接口：搜索图书
    @GetMapping("/search")
    @ResponseBody
    public Map<String, Object> searchBooksAjax(@RequestParam String keyword) {
        Map<String, Object> result = new HashMap<>();
        try {
            List<Book> books = bookService.searchBooks(keyword, null);
            result.put("success", true);
            result.put("books", books);
            result.put("count", books.size());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "搜索失败：" + e.getMessage());
        }
        return result;
    }

    // AJAX接口：获取图书统计
    @GetMapping("/statistics")
    @ResponseBody
    public Map<String, Object> getBookStatistics() {
        Map<String, Object> result = new HashMap<>();
        try {
            List<Book> books = bookService.getAllBooks();

            // 统计分类
            Map<String, Integer> categoryStats = new HashMap<>();
            int totalBooks = 0;
            int availableBooks = 0;

            for (Book book : books) {
                totalBooks += book.getTotalCopies();
                availableBooks += book.getAvailableCopies();

                String category = book.getCategory();
                Integer count = categoryStats.get(category);
                categoryStats.put(category, (count != null ? count : 0) + 1);}

            result.put("success", true);
            result.put("totalBooks", books.size());
            result.put("totalCopies", totalBooks);
            result.put("availableCopies", availableBooks);
            result.put("borrowedCopies", totalBooks - availableBooks);
            result.put("categoryStats", categoryStats);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取统计信息失败：" + e.getMessage());
        }
        return result;
    }

    @GetMapping("/quicklist")
    @ResponseBody
    public List<Book> getQuickBookList() {
        return bookService.getAllBooks();
    }

    @GetMapping("/chartData")
    @ResponseBody
    public Map<String, Object> getChartData() {
        Map<String, Object> chartData = new HashMap<>();

        // 图书分类统计
        List<Book> books = bookService.getAllBooks();
        Map<String, Integer> categoryCount = new HashMap<>();

        for (Book book : books) {
            String category = book.getCategory() != null ? book.getCategory() : "未分类";
            Integer current = categoryCount.get(category);
            categoryCount.put(category, (current != null ? current : 0) + 1);}

        // 借阅趋势（最近30天）
        List<Map<String, Object>> borrowTrend = null;
        try {
            // 调用借阅服务获取趋势数据
            borrowTrend = borrowService.getBorrowTrend(30);
            System.out.println("获取到借阅趋势数据，条数: " + (borrowTrend != null ? borrowTrend.size() : 0));
        } catch (Exception e) {
            // 如果方法不存在或出错，使用空数据
            e.printStackTrace();
            borrowTrend = new ArrayList<>();
            System.out.println("获取借阅趋势数据失败: " + e.getMessage());
        }

        chartData.put("categoryData", categoryCount);
        chartData.put("borrowTrend", borrowTrend);
        chartData.put("success", true);

        return chartData;
    }
}
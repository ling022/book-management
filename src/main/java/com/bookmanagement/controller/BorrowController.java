package com.bookmanagement.controller;

import com.bookmanagement.entity.Book;
import com.bookmanagement.entity.BorrowRecord;
import com.bookmanagement.service.BookService;
import com.bookmanagement.service.BorrowService;
import com.bookmanagement.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/borrow")
public class BorrowController {

    @Autowired
    private BorrowService borrowService;

    @Autowired
    private BookService bookService;

    @Autowired
    private UserService userService;

    // 显示借阅记录列表
    @GetMapping("/list")
    public String listBorrowRecords(Model model,
                                    @RequestParam(value = "page", defaultValue = "1") int page,
                                    HttpSession session) {
        try {
            String role = (String) session.getAttribute("role");
            Integer userId = (Integer) session.getAttribute("userId");

            // 调试信息
            System.out.println("=== BorrowController.listBorrowRecords ===");
            System.out.println("用户角色: " + role);
            System.out.println("用户ID: " + userId);

            List<BorrowRecord> records;

            // 普通用户只能查看自己的借阅记录，管理员可以查看所有
            if ("ADMIN".equals(role)) {
                records = borrowService.getAllBorrowRecords();
                System.out.println("管理员查询所有记录，数量: " + (records != null ? records.size() : 0));
            } else if (userId != null) {
                records = borrowService.getBorrowRecordsByUserId(userId);
                System.out.println("用户查询自己的记录，用户ID: " + userId + ", 数量: " + (records != null ? records.size() : 0));
            } else {
                // 未登录
                System.out.println("用户未登录，重定向到登录页面");
                return "redirect:/user/login";
            }

            model.addAttribute("records", records);
            model.addAttribute("currentPage", page);

            // 如果没有记录，显示提示
            if (records == null || records.isEmpty()) {
                model.addAttribute("infoMessage", "暂无借阅记录");
                System.out.println("没有找到借阅记录");
            } else {
                System.out.println("找到 " + records.size() + " 条记录");
                // 打印每条记录
                for (BorrowRecord record : records) {
                    System.out.println("记录ID: " + record.getId() +
                            ", 图书ID: " + record.getBookId() +
                            ", 状态: " + record.getStatus());
                }
            }

            return "borrow/list";
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("errorMessage", "加载借阅记录失败: " + e.getMessage());
            return "borrow/list";
        }
    }

    // 显示借书页面
    @GetMapping("/add")
    public String showBorrowForm(Model model, HttpSession session,
                                 @RequestParam(value = "bookId", required = false) Integer bookId) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            model.addAttribute("errorMessage", "请先登录！");
            model.addAttribute("needRedirect", true);
            return "borrow/add";
        }

        String role = (String) session.getAttribute("role");
        if (!"USER".equals(role)) {
            model.addAttribute("errorMessage", "权限不足！只有普通用户可以借阅图书。");
            return "borrow/add";
        }
// 如果有bookId参数，将其添加到模型中
        if (bookId != null) {
            model.addAttribute("preselectedBookId", bookId);

            // 检查该书是否可借
            Book book = bookService.getBookById(bookId);
            if (book != null) {
                boolean canBorrow = book.getAvailableCopies() > 0 &&
                        !"MAINTENANCE".equals(book.getStatus());
                model.addAttribute("preselectedBookAvailable", canBorrow);
                model.addAttribute("preselectedBookTitle", book.getTitle());
            }
        }

        // ====== 修改：只查询可借阅的图书 ======
        List<Book> allBooks = bookService.getAllBooks();
        List<Book> availableBooks = new ArrayList<Book>();
        for (Book book : allBooks) {
            if (book.getAvailableCopies() > 0 &&
                    !"MAINTENANCE".equals(book.getStatus())) {
                availableBooks.add(book);
            }
        }

        model.addAttribute("books", availableBooks);
        model.addAttribute("borrowNotice", getBorrowNotice());

        // ====== 新增：如果有维护中的图书，给出提示 ======
        // Java 7兼容写法
        int maintenanceCount = 0;
        for (Book book : allBooks) {
            if ("MAINTENANCE".equals(book.getStatus())) {
                maintenanceCount++;
            }
        }

        if (maintenanceCount > 0) {
            model.addAttribute("infoMessage",
                    "当前有 " + maintenanceCount + " 本图书维护中，暂时不可借阅");
        }

        return "borrow/add";
    }

    // 获取借阅须知内容
    private Map<String, String> getBorrowNotice() {
        Map<String, String> notice = new HashMap<>();
        notice.put("title", "借阅须知");
        notice.put("content", "1. 借阅到期前可以续借一次\n" +
                "2. 逾期未还将产生逾期记录\n" +
                "3. 请妥善保管所借图书\n" +
                "4. 如有疑问请联系管理员");
        return notice;
    }

    // 处理借书请求 - GET方法
    @GetMapping("/borrow")
    public String borrowBook(@RequestParam Integer bookId,
                             @RequestParam(defaultValue = "30") Integer days,
                             HttpSession session,
                             RedirectAttributes redirectAttributes) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "请先登录！");
                redirectAttributes.addFlashAttribute("showDirectly", true);
                return "redirect:/borrow/add";
            }

            // 检查用户权限 - 只有USER可以借书
            String role = (String) session.getAttribute("role");
            if (!"USER".equals(role)) {
                redirectAttributes.addFlashAttribute("errorMessage", "只有普通用户可以借书！");
                redirectAttributes.addFlashAttribute("showDirectly", true);
                return "redirect:/borrow/add";
            }

            System.out.println("用户借书 - 用户ID: " + userId + ", 图书ID: " + bookId + ", 天数: " + days);

            boolean success = borrowService.borrowBook(userId, bookId, days);
            if (success) {
                redirectAttributes.addFlashAttribute("successMessage", "借书成功！");
                System.out.println("借书成功");
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "借书失败，可能图书已全部借出或您已借阅该书！");
                redirectAttributes.addFlashAttribute("showDirectly", true);
                System.out.println("借书失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            // ====== 关键修改：根据异常类型显示不同消息 ======
            String errorMsg = e.getMessage();
            if (errorMsg.contains("逾期未还") || errorMsg.contains("逾期图书")) {
                redirectAttributes.addFlashAttribute("errorMessage",
                        "借书失败：您有逾期未还的图书，请先联系图书管理员归还逾期图书！");
            } else if (errorMsg.contains("已逾期未还")) {
                redirectAttributes.addFlashAttribute("errorMessage",
                        "借书失败：该书您已逾期未还，请先联系图书管理员归还逾期图书！");
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "借书失败：" + e.getMessage());
            }
            redirectAttributes.addFlashAttribute("showDirectly", true);
        }
        return "redirect:/borrow/list";
    }

    // 处理还书请求
    @GetMapping("/return/{id}")
    public String returnBook(@PathVariable Integer id,
                             HttpSession session,
                             RedirectAttributes redirectAttributes) {
        try {
            String role = (String) session.getAttribute("role");
            BorrowRecord record = borrowService.getBorrowRecordById(id);

            if (record == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "借阅记录不存在！ID: " + id);
                return "redirect:/borrow/list";
            }

            if ("RETURNED".equals(record.getStatus())) {
                redirectAttributes.addFlashAttribute("errorMessage", "图书已归还，无需重复操作！");
                return "redirect:/borrow/list";
            }

            // 权限检查：管理员或借阅者本人
            if (!"ADMIN".equals(role)) {
                Integer userId = (Integer) session.getAttribute("userId");
                if (!userId.equals(record.getUserId())) {
                    redirectAttributes.addFlashAttribute("errorMessage", "权限不足！只能归还自己借阅的图书。");
                    return "redirect:/borrow/list";
                }
            }

            System.out.println("还书操作 - 记录ID: " + id + ", 用户ID: " + record.getUserId());

            boolean success = borrowService.returnBook(id);
            if (success) {
                redirectAttributes.addFlashAttribute("successMessage",
                        "还书成功！图书《" + (record.getBook() != null ? record.getBook().getTitle() : "") + "》已归还");
                System.out.println("还书成功");
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "还书失败，请稍后重试！");
                System.out.println("还书失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage",
                    "还书失败：" + e.getMessage() + "。记录ID: " + id);
        }
        return "redirect:/borrow/list";
    }

    // 处理续借请求
    @GetMapping("/renew/{id}")
    public String renewBook(@PathVariable Integer id,
                            @RequestParam(defaultValue = "15") Integer additionalDays,
                            HttpSession session,
                            RedirectAttributes redirectAttributes) {
        try {
            // 权限检查
            BorrowRecord record = borrowService.getBorrowRecordById(id);
            if (record == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "借阅记录不存在！");
                return "redirect:/borrow/list";
            }

            String role = (String) session.getAttribute("role");
            if (!"ADMIN".equals(role)) {
                Integer userId = (Integer) session.getAttribute("userId");
                if (!userId.equals(record.getUserId())) {
                    redirectAttributes.addFlashAttribute("errorMessage", "权限不足！只能续借自己借阅的图书。");
                    return "redirect:/borrow/list";
                }
            }


            boolean success = borrowService.renewBook(id, additionalDays);
            if (success) {
                redirectAttributes.addFlashAttribute("successMessage", "续借成功！");
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "续借失败，可能已逾期！");
            }
        } catch (Exception e) {
            // 捕获维护状态的异常
            if (e.getMessage().contains("维护中")) {
                redirectAttributes.addFlashAttribute("errorMessage", "续借失败，图书正在维护中！");
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "续借失败：" + e.getMessage());
            }
        }
        return "redirect:/borrow/list";
    }

    // 查看借阅详情
    @GetMapping("/detail/{id}")
    public String viewBorrowDetail(@PathVariable Integer id, Model model, HttpSession session) {
        BorrowRecord record = borrowService.getBorrowRecordById(id);
        if (record == null) {
            model.addAttribute("errorMessage", "借阅记录不存在！");
            return "redirect:/borrow/list";
        }

        // 权限检查
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            Integer userId = (Integer) session.getAttribute("userId");
            if (!userId.equals(record.getUserId())) {
                model.addAttribute("errorMessage", "权限不足！");
                return "redirect:/borrow/list";
            }
        }

        model.addAttribute("record", record);
        model.addAttribute("isOverdue", borrowService.checkOverdue(id));

        return "borrow/detail";
    }

    // AJAX接口：获取借阅统计
    @GetMapping("/statistics")
    @ResponseBody
    public Map<String, Object> getBorrowStatistics() {
        return borrowService.getBorrowStatistics();
    }

    // AJAX接口：获取借阅趋势数据
    @GetMapping("/trend")
    @ResponseBody
    public Map<String, Object> getBorrowTrendData(@RequestParam(defaultValue = "30") int days) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 基础趋势数据
            List<Map<String, Object>> trendData = borrowService.getBorrowTrend(days);

            result.put("success", true);
            result.put("trendData", trendData);
            result.put("message", "获取借阅趋势数据成功");

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取借阅趋势数据失败: " + e.getMessage());
        }

        return result;
    }

    // AJAX接口：检查图书是否可借
    @GetMapping("/checkAvailability/{bookId}")
    @ResponseBody
    public Map<String, Object> checkAvailability(@PathVariable Integer bookId) {
        Map<String, Object> result = new HashMap<>();
        try {
            com.bookmanagement.entity.Book book = bookService.getBookById(bookId);
            if (book != null) {
                // 检查图书状态
                boolean canBorrow = book.getAvailableCopies() > 0 &&
                        !"MAINTENANCE".equals(book.getStatus());

                result.put("available", canBorrow);
                result.put("availableCopies", book.getAvailableCopies());
                result.put("status", book.getStatus());
                result.put("message", canBorrow ? "可借" :
                        "MAINTENANCE".equals(book.getStatus()) ? "图书维护中" : "已全部借出");
            } else {
                result.put("available", false);
                result.put("message", "图书不存在");
            }
        } catch (Exception e) {
            result.put("available", false);
            result.put("message", "检查失败");
        }
        return result;
    }
}
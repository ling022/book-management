package com.bookmanagement.controller;

import com.bookmanagement.entity.User;
import com.bookmanagement.service.UserService;
import com.bookmanagement.util.MD5Util;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    // 显示登录页面
    @GetMapping("/login")
    public String showLoginForm() {
        return "user/login";
    }

    // 处理登录请求
    @PostMapping("/login")
    public String login(@RequestParam String username,
                        @RequestParam String password,
                        HttpSession session,
                        RedirectAttributes redirectAttributes) {
        try {
            User user = userService.login(username, password);
            if (user != null) {
                // 登录成功，将用户信息存入session
                session.setAttribute("user", user);
                session.setAttribute("username", user.getUsername());
                session.setAttribute("role", user.getRole());
                session.setAttribute("userId", user.getId());

                System.out.println("登录成功！用户: " + user.getUsername() + ", 角色: " + user.getRole());

                redirectAttributes.addFlashAttribute("successMessage", "登录成功！");
                return "redirect:/";
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "用户名或密码错误！");
                return "redirect:/user/login";
            }
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "登录失败：" + e.getMessage());
            return "redirect:/user/login";
        }
    }

    // 退出登录 - 修复该方法
    @GetMapping("/logout")
    public String logout(HttpSession session, RedirectAttributes redirectAttributes) {
        try {
            String username = (String) session.getAttribute("username");
            if (username != null) {
                System.out.println("用户退出登录: " + username);
            }

            // 清除session
            session.invalidate();

            redirectAttributes.addFlashAttribute("successMessage", "已成功退出登录");
            return "redirect:/";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "退出登录失败");
            return "redirect:/";
        }
    }

    // 显示注册页面
    @GetMapping("/register")
    public String showRegisterForm(Model model) {
        model.addAttribute("user", new User());
        return "user/register";
    }

    // 处理注册请求 - 改为返回视图
    @PostMapping("/register")
    public String register(@ModelAttribute User user,
                           HttpSession session,
                           RedirectAttributes redirectAttributes,
                           Model model) {

        try {
            System.out.println("=== 处理注册请求（视图方式）===");
            System.out.println("用户名: " + user.getUsername());
            System.out.println("密码: " + user.getPassword());
            System.out.println("邮箱: " + user.getEmail());
            System.out.println("电话: " + user.getPhone());

            // 基本验证
            if (user.getUsername() == null || user.getUsername().trim().isEmpty()) {
                model.addAttribute("errorMessage", "用户名不能为空");
                model.addAttribute("user", user); // 保留已填信息
                return "user/register";
            }

            if (user.getPassword() == null || user.getPassword().trim().isEmpty()) {
                model.addAttribute("errorMessage", "密码不能为空");
                model.addAttribute("user", user);
                return "user/register";
            }

            // 验证用户名长度
            if (user.getUsername().trim().length() < 3 || user.getUsername().trim().length() > 20) {
                model.addAttribute("errorMessage", "用户名长度应在3-20个字符之间");
                model.addAttribute("user", user);
                return "user/register";
            }

            // 验证密码长度
            if (user.getPassword().trim().length() < 6) {
                model.addAttribute("errorMessage", "密码长度至少为6位");
                model.addAttribute("user", user);
                return "user/register";
            }

            // 调用服务层注册
            boolean success = userService.register(user);
            if (success) {
                redirectAttributes.addFlashAttribute("successMessage", "注册成功，请登录！");
                return "redirect:/user/login";
            } else {
                model.addAttribute("errorMessage", "用户名已存在，请使用其他用户名！");
                model.addAttribute("user", user);
                return "user/register";
            }
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("errorMessage", "注册失败：" + e.getMessage());
            model.addAttribute("user", user);
            return "user/register";
        }
    }

    // 显示用户列表（需要管理员权限）
    @GetMapping("/list")
    public String listUsers(Model model,
                            @RequestParam(value = "page", defaultValue = "1") int page,
                            @RequestParam(value = "keyword", required = false) String keyword,
                            HttpSession session) {
        // 检查权限
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            model.addAttribute("errorMessage", "权限不足！只有管理员可以查看用户列表。");
            return "redirect:/";
        }

        int pageSize = 10;
        int totalUsers = userService.getUserCount();
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);
        int currentPage = Math.max(1, Math.min(page, totalPages));

        // 获取用户列表
        java.util.List<User> users = userService.getUsersByPage(currentPage, pageSize);

        // 将用户信息存入session，以便编辑页面可以访问
        if (users != null) {
            // 创建一个用户ID到用户对象的映射，存入session
            Map<Integer, User> userMap = new HashMap<>();
            for (User user : users) {
                userMap.put(user.getId(), user);
            }
            session.setAttribute("userMap", userMap);
        }

        model.addAttribute("users", users);
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalUsers", totalUsers);
        model.addAttribute("keyword", keyword);

        return "user/list";
    }


    // 删除用户（需要管理员权限）
    @GetMapping("/delete/{id}")
    @ResponseBody
    public Map<String, Object> deleteUser(@PathVariable Integer id,
                                          HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 检查权限
            String role = (String) session.getAttribute("role");
            if (!"ADMIN".equals(role)) {
                result.put("success", false);
                result.put("message", "权限不足！只有管理员可以删除用户。");
                return result;
            }

            // 获取当前用户ID
            Integer currentUserId = (Integer) session.getAttribute("userId");

            // 不能删除自己
            if (currentUserId != null && currentUserId.equals(id)) {
                result.put("success", false);
                result.put("message", "不能删除当前登录的用户！");
                return result;
            }

            // 也不能删除其他管理员（可选）
            User userToDelete = userService.getUserById(id);
            if (userToDelete != null && "ADMIN".equals(userToDelete.getRole())) {
                result.put("success", false);
                result.put("message", "不能删除其他管理员！");
                return result;
            }

            boolean success = userService.deleteUser(id);
            if (success) {
                result.put("success", true);
                result.put("message", "用户删除成功！");
            } else {
                result.put("success", false);
                result.put("message", "用户删除失败！");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "删除失败：" + e.getMessage());
        }
        return result;
    }

    // 显示编辑用户页面（管理员用）
    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Integer id,
                               Model model,
                               HttpSession session,
                               RedirectAttributes redirectAttributes) {
        // 检查权限
        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            redirectAttributes.addFlashAttribute("errorMessage", "权限不足！只有管理员可以编辑用户。");
            return "redirect:/user/list";
        }

        // 首先尝试从session中的userMap获取用户信息
        Map<Integer, User> userMap = (Map<Integer, User>) session.getAttribute("userMap");
        User user = null;

        if (userMap != null) {
            user = userMap.get(id);
        }

        // 如果session中没有，再从数据库获取
        if (user == null) {
            user = userService.getUserById(id);
        }

        if (user == null) {
            // 使用直接显示的消息，不在右上角显示
            model.addAttribute("directErrorMessage", "用户不存在！");
            return "user/list"; // 返回用户列表页面
        }

        model.addAttribute("user", user);
        return "user/edit";
    }

    // 处理用户更新（管理员用）
    @PostMapping("/update")
    public String updateUser(@ModelAttribute User user,
                             @RequestParam(value = "resetPassword", defaultValue = "false") boolean resetPassword,
                             HttpSession session,
                             RedirectAttributes redirectAttributes) {
        try {
            System.out.println("=== 管理员更新用户信息 ===");
            System.out.println("用户ID: " + user.getId());
            System.out.println("重置密码: " + resetPassword);

            // 检查权限
            String role = (String) session.getAttribute("role");
            if (!"ADMIN".equals(role)) {
                redirectAttributes.addFlashAttribute("errorMessage", "权限不足！只有管理员可以更新用户信息。");
                return "redirect:/user/list";
            }

            // 获取数据库中的原用户信息
            User existingUser = userService.getUserById(user.getId());
            if (existingUser == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "用户不存在！");
                return "redirect:/user/list";
            }

            // 创建要更新的用户对象
            User userToUpdate = new User();
            userToUpdate.setId(user.getId());
            userToUpdate.setUsername(existingUser.getUsername()); // 用户名不变
            userToUpdate.setEmail(existingUser.getEmail()); // 邮箱不变
            userToUpdate.setPhone(existingUser.getPhone()); // 电话不变
            userToUpdate.setRole(existingUser.getRole()); // 角色不变

            // 设置密码
            if (resetPassword) {
                // 重置为默认密码 "123456"，并加密
                String defaultPassword = "123456";
                userToUpdate.setPassword(MD5Util.md5(defaultPassword));
                System.out.println("密码重置为: " + defaultPassword + " (加密后: " + MD5Util.md5(defaultPassword) + ")");
            } else {
                // 保持原密码
                userToUpdate.setPassword(existingUser.getPassword());
                System.out.println("保持原密码");
            }

            boolean success = userService.updateUser(userToUpdate);
            if (success) {
                if (resetPassword) {
                    redirectAttributes.addFlashAttribute("successMessage",
                            "用户【" + existingUser.getUsername() + "】的密码重置成功！");
                } else {
                    redirectAttributes.addFlashAttribute("successMessage",
                            "用户信息更新成功！");
                }
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "用户更新失败！");
            }
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "更新失败：" + e.getMessage());
        }
        return "redirect:/user/list";
    }

    // 显示个人资料
    @GetMapping("/profile")
    public String showProfile(HttpSession session, Model model) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return "redirect:/user/login";
        }

        User user = userService.getUserById(userId);
        model.addAttribute("user", user);
        return "user/profile";
    }

    // 更新个人资料 - 用户自己修改信息
    @PostMapping("/profile")
    public String updateProfile(@ModelAttribute User user,
                                HttpSession session,
                                RedirectAttributes redirectAttributes) {
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                return "redirect:/user/login";
            }

            System.out.println("=== 用户修改个人资料 ===");
            System.out.println("用户ID: " + userId);
            System.out.println("新用户名: " + user.getUsername());
            System.out.println("新邮箱: " + user.getEmail());
            System.out.println("新电话: " + user.getPhone());

            // 设置当前用户ID
            user.setId(userId);

            // 检查用户名是否已存在（如果是修改用户名）
            if (user.getUsername() != null && !user.getUsername().trim().isEmpty()) {
                User existingUser = userService.getUserById(userId);
                // 如果用户名有变化，检查是否与其他用户冲突
                if (!existingUser.getUsername().equals(user.getUsername().trim())) {
                    if (userService.isUsernameExist(user.getUsername())) {
                        redirectAttributes.addFlashAttribute("errorMessage", "用户名已存在，请使用其他用户名！");
                        return "redirect:/user/profile";
                    }
                }
            }

            // 获取原用户信息
            User existingUser = userService.getUserById(userId);

            // 用户自己不能修改密码（通过changePassword方法）
            // 用户自己不能修改角色
            // 设置原密码，避免密码被清空
            user.setPassword(existingUser.getPassword()); // 保持原密码
            user.setRole(existingUser.getRole()); // 保持原角色

            System.out.println("提交更新到Service层...");

            boolean success = userService.updateUser(user);
            if (success) {
                // 更新session中的用户名
                session.setAttribute("username", user.getUsername());

                redirectAttributes.addFlashAttribute("successMessage", "个人资料更新成功！");
                System.out.println("资料更新成功");
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "资料更新失败！");
                System.out.println("资料更新失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "更新失败：" + e.getMessage());
        }
        return "redirect:/user/profile";
    }

    // AJAX接口：修改密码
    @PostMapping("/changePassword")
    @ResponseBody
    public Map<String, Object> changePasswordAjax(@RequestParam String oldPassword,
                                                  @RequestParam String newPassword,
                                                  @RequestParam String confirmPassword,
                                                  HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                result.put("success", false);
                result.put("message", "请先登录");
                return result;
            }

            // 验证新密码和确认密码是否一致
            if (!newPassword.equals(confirmPassword)) {
                result.put("success", false);
                result.put("message", "新密码和确认密码不一致！");
                return result;
            }

            // 验证新密码长度
            if (newPassword.length() < 6) {
                result.put("success", false);
                result.put("message", "新密码长度至少为6位！");
                return result;
            }

            // 调用Service层修改密码
            try {
                boolean success = userService.changePassword(userId, oldPassword, newPassword);

                if (success) {
                    result.put("success", true);
                    result.put("message", "密码修改成功！");
                } else {
                    result.put("success", false);
                    result.put("message", "密码修改失败！");
                }

            } catch (RuntimeException e) {
                String errorMsg = e.getMessage();
                if (errorMsg != null && errorMsg.contains("旧密码")) {
                    result.put("success", false);
                    result.put("message", "旧密码错误，请重新输入！");
                } else {
                    result.put("success", false);
                    result.put("message", "修改失败：" + errorMsg);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "修改失败：" + e.getMessage());
        }

        return result;
    }

    // AJAX接口：更新个人资料
    @PostMapping("/profile/update")
    @ResponseBody
    public Map<String, Object> updateProfileAjax(@ModelAttribute User user,
                                                 HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                result.put("success", false);
                result.put("message", "用户未登录");
                return result;
            }

            // 确保只能修改自己的信息
            user.setId(userId);

            // 获取当前用户信息
            User currentUser = userService.getUserById(userId);
            if (currentUser == null) {
                result.put("success", false);
                result.put("message", "用户不存在");
                return result;
            }

            // 检查用户名是否已存在（如果修改了用户名）
            if (!currentUser.getUsername().equals(user.getUsername())) {
                if (userService.isUsernameExist(user.getUsername())) {
                    result.put("success", false);
                    result.put("message", "用户名已存在，请使用其他用户名");
                    return result;
                }
            }

            // 保留原有密码和角色
            user.setPassword(currentUser.getPassword());
            user.setRole(currentUser.getRole());

            boolean success = userService.updateUser(user);
            if (success) {
                // 更新session中的用户名
                session.setAttribute("username", user.getUsername());
                result.put("success", true);
                result.put("message", "个人资料更新成功");
            } else {
                result.put("success", false);
                result.put("message", "个人资料更新失败");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "更新异常：" + e.getMessage());
        }
        return result;
    }

    // AJAX接口：检查用户名是否可用
    @GetMapping("/checkUsername")
    @ResponseBody
    public Map<String, Object> checkUsername(@RequestParam String username) {
        Map<String, Object> result = new HashMap<>();
        try {
            boolean exists = userService.isUsernameExist(username);
            result.put("available", !exists);
            result.put("message", exists ? "用户名已存在" : "用户名可用");
        } catch (Exception e) {
            result.put("available", false);
            result.put("message", "检查失败");
        }
        return result;
    }
}
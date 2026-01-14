package com.bookmanagement.service;

import com.bookmanagement.entity.User;
import java.util.List;

public interface UserService {
    // 用户注册
    boolean register(User user);

    // 用户登录
    User login(String username, String password);

    // 更新用户信息
    boolean updateUser(User user);



    // 删除用户
    boolean deleteUser(Integer id);

    // 获取所有用户
    List<User> getAllUsers();

    // 根据ID获取用户
    User getUserById(Integer id);

    // 检查用户名是否存在
    boolean isUsernameExist(String username);

    // 修改密码
    boolean changePassword(Integer userId, String oldPassword, String newPassword);

    // 分页查询用户
    List<User> getUsersByPage(int page, int pageSize);

    // 获取用户总数
    int getUserCount();
}
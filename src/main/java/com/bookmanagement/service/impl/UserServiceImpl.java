package com.bookmanagement.service.impl;

import com.bookmanagement.dao.UserMapper;
import com.bookmanagement.entity.User;
import com.bookmanagement.service.UserService;
import com.bookmanagement.util.MD5Util;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    private static final Logger logger = LoggerFactory.getLogger(UserServiceImpl.class);

    @Override
    @Transactional
    public boolean register(User user) {
        try {
            System.out.println("=== 开始注册用户 ===");
            System.out.println("用户名: " + user.getUsername());

            // 检查用户名是否已存在
            if (isUsernameExist(user.getUsername())) {
                System.out.println("用户名已存在: " + user.getUsername());
                return false;
            }

            // 对密码进行MD5加密
            String encryptedPassword = MD5Util.md5(user.getPassword());
            user.setPassword(encryptedPassword);
            System.out.println("加密后密码: " + encryptedPassword);

            // 设置默认角色（移除super_admin设置）
            if (user.getRole() == null || user.getRole().trim().isEmpty()) {
                user.setRole("USER");
            }
            // 移除 super_admin 设置

            if (user.getEmail() == null) user.setEmail("");
            if (user.getPhone() == null) user.setPhone("");

            System.out.println("准备插入用户: " + user);

            int result = userMapper.insertUser(user);
            System.out.println("插入结果: " + result);

            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("用户注册失败: " + e.getMessage());
            throw new RuntimeException("用户注册失败", e);
        }
    }

    @Override
    public User login(String username, String password) {
        try {
            logger.info("用户尝试登录: {}", username);

            // 对密码进行MD5加密后验证
            String encryptedPassword = MD5Util.md5(password);
            logger.debug("加密后密码: {}", encryptedPassword);

            User user = userMapper.login(username, encryptedPassword);

            if (user != null) {
                logger.info("登录成功: {}，角色: {}", username, user.getRole());
            } else {
                logger.warn("登录失败: {}", username);
            }

            return user;
        } catch (Exception e) {
            logger.error("登录异常: {}", username, e);
            throw new RuntimeException("登录失败", e);
        }
    }

    @Override
    public boolean updateUser(User user) {
        try {
            logger.info("=== 开始更新用户信息 ===");
            logger.info("用户ID: {}", user.getId());
            logger.info("传入的用户名: {}", user.getUsername());
            logger.info("传入的邮箱: {}", user.getEmail());
            logger.info("传入的电话: {}", user.getPhone());

            // 从数据库获取原用户信息
            User existingUser = userMapper.selectUserById(user.getId());
            if (existingUser == null) {
                logger.error("要更新的用户不存在，ID: {}", user.getId());
                return false;
            }

            logger.info("数据库原数据 - 用户名: {}, 密码: {}, 邮箱: {}, 电话: {}",
                    existingUser.getUsername(), existingUser.getPassword(),
                    existingUser.getEmail(), existingUser.getPhone());

            // 创建要更新的用户对象
            User userToUpdate = new User();
            userToUpdate.setId(user.getId());

            // 1. 用户名处理
            if (user.getUsername() != null && !user.getUsername().trim().isEmpty()) {
                userToUpdate.setUsername(user.getUsername().trim());
            } else {
                userToUpdate.setUsername(existingUser.getUsername());
            }

            // 2. 邮箱处理
            userToUpdate.setEmail(user.getEmail());

            // 3. 电话处理
            userToUpdate.setPhone(user.getPhone());

            // 4. 角色保持不变
            userToUpdate.setRole(existingUser.getRole());

            // 5. 密码处理
            if (user.getPassword() != null && !user.getPassword().trim().isEmpty()) {
                String password = user.getPassword().trim();
                // 检查是否是32位MD5字符串
                if (password.length() == 32) {
                    // 已经是MD5格式，直接使用
                    userToUpdate.setPassword(password);
                    logger.info("使用传入的MD5加密密码");
                } else {
                    // 明文密码，进行MD5加密
                    userToUpdate.setPassword(MD5Util.md5(password));
                    logger.info("将明文密码加密为MD5");
                }
            } else {
                // 没有传入密码，保持原密码
                userToUpdate.setPassword(existingUser.getPassword());
                logger.info("保持原密码不变");
            }

            logger.info("最终更新数据 - ID: {}, 用户名: {}, 邮箱: {}, 电话: {}, 密码长度: {}",
                    userToUpdate.getId(), userToUpdate.getUsername(),
                    userToUpdate.getEmail(), userToUpdate.getPhone(),
                    userToUpdate.getPassword() != null ? userToUpdate.getPassword().length() : 0);

            // 执行更新
            int result = userMapper.updateUser(userToUpdate);
            logger.info("数据库更新结果: {}, 影响行数: {}", result > 0 ? "成功" : "失败", result);

            return result > 0;
        } catch (Exception e) {
            logger.error("更新用户信息失败，用户ID: {}", user.getId(), e);
            throw new RuntimeException("更新用户信息失败: " + e.getMessage(), e);
        }
    }

    @Override
    public boolean deleteUser(Integer id) {
        try {
            User currentUser = userMapper.selectUserById(id);
            if (currentUser == null) {
                logger.warn("要删除的用户不存在，ID: {}", id);
                return false;
            }
            int result = userMapper.deleteUser(id);
            logger.info("删除用户结果: {}, ID: {}", result, id);
            return result > 0;
        } catch (Exception e) {
            logger.error("删除用户失败，ID: {}", id, e);
            throw new RuntimeException("删除用户失败", e);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<User> getAllUsers() {
        return userMapper.selectAllUsers();
    }

    @Override
    @Transactional(readOnly = true)
    public User getUserById(Integer id) {
        return userMapper.selectUserById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isUsernameExist(String username) {
        User user = userMapper.selectUserByUsername(username);
        return user != null;
    }

    @Override
    public boolean changePassword(Integer userId, String oldPassword, String newPassword) {
        try {
            User user = userMapper.selectUserById(userId);
            if (user == null) {
                logger.error("用户不存在，ID: {}", userId);
                throw new RuntimeException("用户不存在");
            }

            // 验证旧密码
            String encryptedOldPassword = MD5Util.md5(oldPassword);
            logger.info("验证旧密码 - 输入加密后: {}, 数据库: {}",
                    encryptedOldPassword, user.getPassword());

            // 这里要明确检查密码是否正确
            if (user.getPassword() == null || !encryptedOldPassword.equals(user.getPassword())) {
                logger.error("旧密码验证失败 - 用户ID: {}", userId);
                // 明确抛出异常，让Controller能捕获到具体原因
                throw new RuntimeException("旧密码错误");
            }

            // 更新密码
            user.setPassword(MD5Util.md5(newPassword));
            int result = userMapper.updateUser(user);
            logger.info("修改密码结果: {}, 用户ID: {}", result, userId);

            if (result <= 0) {
                throw new RuntimeException("密码更新失败");
            }
            return true;
        } catch (RuntimeException e) {
            // 重新抛出，让Controller能获取具体错误信息
            throw e;
        } catch (Exception e) {
            logger.error("修改密码失败，用户ID: {}", userId, e);
            throw new RuntimeException("修改密码失败: " + e.getMessage());
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<User> getUsersByPage(int page, int pageSize) {
        try {
            int start = (page - 1) * pageSize;
            // 直接调用 Mapper 的分页查询方法
            return userMapper.selectUsersByPage(start, pageSize);
        } catch (Exception e) {
            logger.error("分页查询用户失败，page: {}, pageSize: {}", page, pageSize, e);
            // 如果分页方法有问题，使用备用方案
            return getAllUsers();
        }
    }

    @Override
    @Transactional(readOnly = true)
    public int getUserCount() {
        return userMapper.countUsers();
    }
}
package com.bookmanagement.dao;

import com.bookmanagement.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
@Mapper
public interface UserMapper {
    // 添加用户
    int insertUser(User user);

    // 删除用户
    int deleteUser(Integer id);

    // 更新用户信息
    int updateUser(User user);

    // 根据ID查询用户
    User selectUserById(Integer id);

    // 根据用户名查询用户
    User selectUserByUsername(String username);

    // 分页查询用户
    List<User> selectUsersByPage(@Param("start") int start,
                                 @Param("pageSize") int pageSize);

    // 查询所有用户
    List<User> selectAllUsers();

    // 用户登录验证
    User login(@Param("username") String username,
               @Param("password") String password);

    // 查询用户总数
    int countUsers();
}
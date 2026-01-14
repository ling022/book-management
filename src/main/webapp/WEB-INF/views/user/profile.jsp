<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人中心 - 图书管理系统</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .profile-container {
            max-width: 800px;
            margin: 0 auto;
        }
        .profile-section {
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .profile-section h4 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .user-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: #007bff;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            font-weight: bold;
            margin: 0 auto 20px;
        }
        .last-login {
            color: #666;
            font-size: 14px;
            text-align: center;
            margin-bottom: 20px;
        }
        .form-note {
            color: #666;
            font-size: 13px;
            margin-top: 5px;
        }
        .loading {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #3498db;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-right: 5px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="user"/>
</jsp:include>

<div class="container profile-container">
    <h2>个人中心</h2>

    <div class="user-avatar">
        ${user.username.charAt(0)}
    </div>

    <div class="last-login">
        注册时间：<fmt:formatDate value="${user.createdTime}" pattern="yyyy-MM-dd HH:mm:ss"/>
    </div>

    <!-- 基本信息修改表单 -->
    <div class="profile-section">
        <h4>修改基本信息</h4>
        <form action="${pageContext.request.contextPath}/user/profile" method="post" id="profileForm">
            <input type="hidden" name="id" value="${user.id}">

            <div class="form-group">
                <label for="username">用户名 *</label>
                <input type="text" class="form-control" id="username" name="username"
                       value="${user.username}" required minlength="4" maxlength="20">
                <div class="form-note">用户名长度应为4-20位字符</div>
            </div>

            <div class="form-group">
                <label for="email">邮箱</label>
                <input type="email" class="form-control" id="email" name="email"
                       value="${user.email}" maxlength="100">
                <div class="form-note">用于接收系统通知</div>
            </div>

            <div class="form-group">
                <label for="phone">电话</label>
                <input type="tel" class="form-control" id="phone" name="phone"
                       value="${user.phone}" maxlength="20">
                <div class="form-note">用于联系您</div>
            </div>

            <div class="form-group">
                <label for="role">用户角色</label>
                <input type="text" class="form-control" id="role"
                       value="${user.role == 'ADMIN' ? '管理员' : '普通用户'}"
                       readonly style="background-color: #f8f9fa;">
                <div class="form-note">用户角色不可修改</div>
            </div>

            <div class="form-group text-center">
                <button type="submit" class="btn btn-primary btn-lg" id="profileSubmitBtn">
                    <span class="glyphicon glyphicon-ok"></span> 保存基本信息
                </button>
            </div>
        </form>
    </div>

    <!-- 密码修改表单 - AJAX方式 -->
    <div class="profile-section">
        <h4>修改密码</h4>
        <form id="passwordForm">
            <div class="form-group">
                <label for="oldPassword">旧密码 *</label>
                <input type="password" class="form-control" id="oldPassword" name="oldPassword"
                       required placeholder="请输入当前密码">
            </div>
            <div class="form-group">
                <label for="newPassword">新密码 *</label>
                <input type="password" class="form-control" id="newPassword" name="newPassword"
                       required placeholder="至少6位字符" minlength="6">
                <div class="form-note">新密码长度至少为6位</div>
            </div>
            <div class="form-group">
                <label for="confirmPassword">确认新密码 *</label>
                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword"
                       required placeholder="再次输入新密码">
            </div>
            <div class="form-group text-center">
                <button type="submit" class="btn btn-warning btn-lg" id="passwordSubmitBtn">
                    <span class="glyphicon glyphicon-lock"></span> 修改密码
                </button>
            </div>
        </form>
    </div>

    <!-- 其他信息展示 -->
    <div class="profile-section">
        <h4>账户信息</h4>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label>用户ID</label>
                    <input type="text" class="form-control" value="${user.id}" readonly>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <label>注册时间</label>
                    <input type="text" class="form-control"
                           value="<fmt:formatDate value="${user.createdTime}" pattern="yyyy-MM-dd HH:mm:ss"/>"
                           readonly>
                </div>
            </div>
        </div>

        <div class="text-center" style="margin-top: 20px;">
            <a href="${pageContext.request.contextPath}/" class="btn btn-default">
                <span class="glyphicon glyphicon-home"></span> 返回首页
            </a>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp"/>

<script>
    $(document).ready(function() {
        // 1. AJAX方式提交密码修改表单
        $('#passwordForm').submit(function(e) {
            e.preventDefault(); // 阻止表单默认提交

            var oldPassword = $('#oldPassword').val();
            var newPassword = $('#newPassword').val();
            var confirmPassword = $('#confirmPassword').val();

            // 客户端验证
            if (!oldPassword) {
                alert('请输入旧密码');
                $('#oldPassword').focus();
                return false;
            }

            if (newPassword.length < 6) {
                alert('新密码长度至少为6位');
                $('#newPassword').focus();
                return false;
            }

            if (newPassword !== confirmPassword) {
                alert('新密码和确认密码不一致');
                $('#confirmPassword').focus();
                return false;
            }

            // 显示加载中
            var submitBtn = $('#passwordSubmitBtn');
            var originalText = submitBtn.html();
            submitBtn.html('<span class="loading"></span> 处理中...').prop('disabled', true);

            // AJAX提交
            $.ajax({
                url: '${pageContext.request.contextPath}/user/changePassword',
                type: 'POST',
                data: {
                    oldPassword: oldPassword,
                    newPassword: newPassword,
                    confirmPassword: confirmPassword
                },
                dataType: 'json',
                success: function(result) {
                    if (result.success) {
                        // 成功提示
                        alert('✅ ' + result.message);
                        // 清空表单
                        $('#oldPassword').val('');
                        $('#newPassword').val('');
                        $('#confirmPassword').val('');
                    } else {
                        // 错误提示
                        alert('❌ ' + result.message);
                        // 如果是旧密码错误，清空旧密码输入框并聚焦
                        if (result.message.includes('旧密码错误') || result.message.includes('旧密码')) {
                            $('#oldPassword').val('');
                            $('#oldPassword').focus();
                        }
                    }
                },
                error: function(xhr, status, error) {
                    // 网络错误提示
                    alert('❌ 请求失败: ' + error);
                    console.error('密码修改请求失败:', xhr, status, error);
                },
                complete: function() {
                    // 恢复按钮状态
                    submitBtn.html(originalText).prop('disabled', false);
                }
            });
        });

        // 2. AJAX方式提交基本信息修改表单
        $('#profileForm').submit(function(e) {
            e.preventDefault(); // 阻止表单默认提交

            var username = $('#username').val().trim();
            if (!username || username.length < 4) {
                alert('用户名至少需要4个字符');
                $('#username').focus();
                return false;
            }

            // 显示加载中
            var submitBtn = $('#profileSubmitBtn');
            var originalText = submitBtn.html();
            submitBtn.html('<span class="loading"></span> 处理中...').prop('disabled', true);

            // AJAX提交
            $.ajax({
                url: '${pageContext.request.contextPath}/user/profile/update',
                type: 'POST',
                data: $(this).serialize(),
                dataType: 'json',
                success: function(result) {
                    if (result.success) {
                        alert('✅ ' + result.message);
                        // 更新页面上的用户名显示（如果需要）
                        // 可以添加刷新页面或更新特定元素
                    } else {
                        alert('❌ ' + result.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('❌ 请求失败: ' + error);
                    console.error('基本信息更新请求失败:', xhr, status, error);
                },
                complete: function() {
                    submitBtn.html(originalText).prop('disabled', false);
                }
            });
        });

        // 3. 表单实时验证
        $('#newPassword').on('input', function() {
            var password = $(this).val();
            if (password.length > 0 && password.length < 6) {
                $(this).css('border-color', '#dc3545');
            } else {
                $(this).css('border-color', '#ced4da');
            }
        });

        $('#confirmPassword').on('input', function() {
            var newPassword = $('#newPassword').val();
            var confirmPassword = $(this).val();

            if (confirmPassword && newPassword !== confirmPassword) {
                $(this).css('border-color', '#dc3545');
            } else {
                $(this).css('border-color', '#ced4da');
            }
        });

        // 4. 输入框获得焦点时移除错误样式
        $('input').on('focus', function() {
            $(this).css('border-color', '#80bdff');
        });

        $('input').on('blur', function() {
            if (!$(this).hasClass('is-invalid')) {
                $(this).css('border-color', '#ced4da');
            }
        });

        // 5. 密码强度提示（可选功能）
        $('#newPassword').on('keyup', function() {
            var password = $(this).val();
            var strength = '';

            if (password.length === 0) {
                strength = '';
            } else if (password.length < 6) {
                strength = '密码太短';
                $(this).css('border-color', '#dc3545');
            } else if (password.length < 8) {
                strength = '密码强度：弱';
                $(this).css('border-color', '#ffc107');
            } else if (password.length < 12) {
                strength = '密码强度：中';
                $(this).css('border-color', '#28a745');
            } else {
                strength = '密码强度：强';
                $(this).css('border-color', '#28a745');
            }

            // 可以在这里显示密码强度提示
            // console.log(strength);
        });

        // 6. 回车键提交表单
        $('#passwordForm input').keypress(function(e) {
            if (e.which === 13) {
                $('#passwordForm').submit();
                return false;
            }
        });

        // 7. 初始化检查
        console.log('个人中心页面加载完成');
    });
</script>
</body>
</html>
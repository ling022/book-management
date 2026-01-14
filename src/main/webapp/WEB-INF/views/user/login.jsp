<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // 设置请求编码（备份，Spring过滤器应该已经处理）
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户登录</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            padding-top: 100px;
        }
        .login-container {
            max-width: 400px;
            margin: 0 auto;
            padding: 30px;
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="login-container">
        <div class="login-header">
            <h2>用户登录</h2>
            <p class="text-muted">图书管理系统</p>
        </div>

        <!-- 错误消息显示 -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${errorMessage}
            </div>
        </c:if>

        <!-- 成功消息显示 -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${successMessage}
            </div>
        </c:if>

        <!-- 登录表单 -->
        <form action="${pageContext.request.contextPath}/user/login" method="post">
            <div class="form-group">
                <label for="username">用户名</label>
                <input type="text" class="form-control" id="username" name="username"
                       placeholder="请输入用户名" required autofocus>
            </div>

            <div class="form-group">
                <label for="password">密码</label>
                <input type="password" class="form-control" id="password" name="password"
                       placeholder="请输入密码" required>
            </div>

            <div class="form-group">
                <button type="submit" class="btn btn-primary btn-block">登录</button>
            </div>

            <div class="text-center">
                <p>还没有账号？<a href="${pageContext.request.contextPath}/user/register">立即注册</a></p>
                <p><a href="${pageContext.request.contextPath}/">返回首页</a></p>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/bootstrap.min.js"></script>
<script>
    $(document).ready(function() {
        // 自动关闭警告框
        setTimeout(function() {
            $('.alert').alert('close');
        }, 5000);

        // 表单验证
        $('form').on('submit', function(e) {
            var username = $('#username').val().trim();
            var password = $('#password').val().trim();

            if (!username) {
                alert('请输入用户名');
                $('#username').focus();
                return false;
            }

            if (!password) {
                alert('请输入密码');
                $('#password').focus();
                return false;
            }

            return true;
        });
    });
</script>
</body>
</html>

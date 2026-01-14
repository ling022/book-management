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
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>编辑用户 - 图书管理系统</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .edit-user-container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .user-avatar-large {
            width: 80px; height: 80px; border-radius: 50%;
            background: #007bff; color: white;
            display: flex; align-items: center; justify-content: center;
            font-size: 32px; font-weight: bold; margin: 0 auto 20px;
        }
        .direct-message {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
            color: #333;
        }
        .direct-error {
            background-color: #f8d7da;
            border-color: #f5c6cb;
            color: #721c24;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="user"/>
</jsp:include>

<div class="container edit-user-container">
    <h2>编辑用户</h2>

    <!-- 直接显示的消息 -->
    <c:if test="${not empty errorMessage and showDirectly}">
        <div class="direct-message direct-error">
            <span class="glyphicon glyphicon-exclamation-sign"></span>
            <strong>错误：</strong> ${errorMessage}
        </div>
    </c:if>

    <c:if test="${sessionScope.role != 'ADMIN'}">
        <div class="direct-message direct-error">
            <span class="glyphicon glyphicon-exclamation-sign"></span>
            <strong>权限不足！</strong> 只有管理员可以编辑用户信息。
        </div>
        <a href="${pageContext.request.contextPath}/user/list" class="btn btn-default">
            <span class="glyphicon glyphicon-arrow-left"></span> 返回用户列表
        </a>
    </c:if>

    <c:if test="${sessionScope.role == 'ADMIN'}">
        <c:if test="${empty user}">
            <div class="direct-message direct-error">
                <span class="glyphicon glyphicon-exclamation-sign"></span>
                <strong>错误：</strong> 用户信息加载失败，请返回用户列表重新选择。
            </div>
            <a href="${pageContext.request.contextPath}/user/list" class="btn btn-default">
                <span class="glyphicon glyphicon-arrow-left"></span> 返回用户列表
            </a>
        </c:if>

        <c:if test="${not empty user}">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">重置用户密码</h3>
                </div>
                <div class="panel-body">
                    <div class="user-avatar-large">${user.username.charAt(0)}</div>

                    <!-- 用户信息展示 - 不会消失 -->
                    <div class="direct-message" style="background-color: #e9ecef; border-color: #ddd;">
                        <h4>用户信息</h4>
                        <p><strong>用户名：</strong> ${user.username}</p>
                        <p><strong>角色：</strong> ${user.role == 'ADMIN' ? '管理员' : '普通用户'}</p>
                        <p><strong>邮箱：</strong> ${empty user.email ? '未设置' : user.email}</p>
                        <p><strong>电话：</strong> ${empty user.phone ? '未设置' : user.phone}</p>
                        <p><strong>用户ID：</strong> ${user.id}</p>
                        <p><strong>注册时间：</strong>
                            <fmt:formatDate value="${user.createdTime}" pattern="yyyy-MM-dd HH:mm:ss"/>
                        </p>
                    </div>

                    <form action="${pageContext.request.contextPath}/user/update" method="post">
                        <input type="hidden" name="id" value="${user.id}">

                        <div class="form-group">
                            <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="resetPassword" value="true" id="resetPassword">
                                    <strong>重置用户【${user.username}】的密码为：123456</strong>
                                </label>
                            </div>
                            <p class="text-muted">管理员只能重置用户密码，不能修改其他信息</p>
                        </div>

                        <div class="form-group text-center">
                            <button type="submit" class="btn btn-primary btn-lg">
                                <span class="glyphicon glyphicon-ok"></span> 确认重置密码
                            </button>
                            <a href="${pageContext.request.contextPath}/user/list" class="btn btn-default btn-lg">
                                <span class="glyphicon glyphicon-remove"></span> 取消
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>
    </c:if>
</div>

<jsp:include page="../footer.jsp"/>

<script>
    $(document).ready(function() {
        $('form').submit(function(e) {
            var resetPassword = $('#resetPassword').is(':checked');

            if (!resetPassword) {
                alert('请勾选"重置密码"选项');
                return false;
            }

            return confirm('确定要将用户【${user.username}】的密码重置为123456吗？');
        });
    });
</script>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.bookmanagement.entity.User" %> <!-- 添加这行导入 -->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // 设置请求编码
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    // 获取当前登录用户ID
    Integer currentUserId = (Integer) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户管理</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .user-table {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            padding: 20px;
            margin-top: 20px;
        }
        .role-admin {
            color: #dc3545;
            font-weight: bold;
        }
        .role-user {
            color: #28a745;
        }
        .current-user {
            background-color: #f8f9fa !important;
            border-left: 4px solid #007bff;
        }
        .cannot-delete {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .btn-xs {
            padding: 3px 8px;
            font-size: 12px;
            margin-right: 3px;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="user"/>
</jsp:include>

<div class="container">
    <h2>用户管理</h2>

    <!-- 操作按钮 -->
    <div style="margin-bottom: 20px;">
        <a href="${pageContext.request.contextPath}/user/list" class="btn btn-primary">
            <span class="glyphicon glyphicon-refresh"></span> 刷新列表
        </a>
        <span class="pull-right text-muted">
            当前用户ID: <%= currentUserId != null ? currentUserId : "未登录" %>
        </span>
    </div>

    <!-- 用户表格 -->
    <div class="user-table">
        <c:choose>
            <c:when test="${not empty users && !users.isEmpty()}">
                <table class="table table-bordered table-hover">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>用户名</th>
                        <th>角色</th>
                        <th>邮箱</th>
                        <th>电话</th>
                        <th>注册时间</th>
                        <th>操作</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${users}" var="user">
                        <%
                            // 获取当前循环的user对象
                            User user = (User) pageContext.getAttribute("user");

                            // 判断是否是当前登录用户
                            boolean isCurrentUser = false;
                            if (currentUserId != null && user != null &&
                                    user.getId() != null && user.getId().equals(currentUserId)) {
                                isCurrentUser = true;
                            }

                            // 判断是否是管理员
                            boolean isAdmin = user != null && "ADMIN".equals(user.getRole());
                        %>
                        <tr class="<%= isCurrentUser ? "current-user" : "" %>">
                            <td>${user.id}</td>
                            <td>
                                    ${user.username}
                                <c:if test="<%= isCurrentUser %>">
                                    <span class="label label-primary" style="margin-left: 5px;">当前用户</span>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${user.role == 'ADMIN'}">
                                        <span class="role-admin">管理员</span>
                                    </c:when>
                                    <c:when test="${user.role == 'USER'}">
                                        <span class="role-user">普通用户</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">${user.role}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${user.email}</td>
                            <td>${user.phone}</td>
                            <td>
                                <fmt:formatDate value="${user.createdTime}" pattern="yyyy-MM-dd HH:mm"/>
                            </td>
                            <td style="min-width: 200px;">
                                <!-- 删除按钮 - 当前用户和管理员不能删除 -->
                                <c:choose>
                                    <c:when test="<%= isCurrentUser %>">
                                        <!-- 当前用户不能删除自己 -->
                                        <button class="btn btn-danger btn-xs cannot-delete" disabled
                                                title="不能删除当前登录的用户">
                                            <span class="glyphicon glyphicon-trash"></span> 删除
                                        </button>
                                    </c:when>
                                    <c:when test="<%= isAdmin && !isCurrentUser %>">
                                        <!-- 不能删除其他管理员 -->
                                        <button class="btn btn-danger btn-xs cannot-delete" disabled
                                                title="不能删除其他管理员">
                                            <span class="glyphicon glyphicon-trash"></span> 删除
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- 可以删除普通用户 -->
                                        <a href="javascript:void(0);"
                                           class="btn btn-danger btn-xs delete-user"
                                           data-id="${user.id}"
                                           data-username="${user.username}">
                                            <span class="glyphicon glyphicon-trash"></span> 删除
                                        </a>
                                    </c:otherwise>
                                </c:choose>

                                <!-- 重置密码按钮（仅对非当前用户的普通用户） -->
                                <c:if test="<%= !isCurrentUser && !isAdmin %>">
                                    <a href="javascript:void(0);"
                                       class="btn btn-info btn-xs reset-password"
                                       data-id="${user.id}"
                                       data-username="${user.username}">
                                        <span class="glyphicon glyphicon-lock"></span> 重置
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

                <!-- 分页 -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation">
                        <ul class="pagination">
                            <li class="${currentPage == 1 ? 'disabled' : ''}">
                                <a href="${pageContext.request.contextPath}/user/list?page=${currentPage - 1}&keyword=${param.keyword}"
                                   aria-label="Previous">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>

                            <c:forEach begin="1" end="${totalPages}" var="page">
                                <li class="${page == currentPage ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/user/list?page=${page}&keyword=${param.keyword}">
                                            ${page}
                                    </a>
                                </li>
                            </c:forEach>

                            <li class="${currentPage == totalPages ? 'disabled' : ''}">
                                <a href="${pageContext.request.contextPath}/user/list?page=${currentPage + 1}&keyword=${param.keyword}"
                                   aria-label="Next">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </c:if>

                <!-- 统计信息 -->
                <div class="text-muted" style="margin-top: 15px;">
                    共 ${totalUsers} 位用户，第 ${currentPage}/${totalPages} 页
                    <c:if test="<%= currentUserId != null %>">
                        | 当前登录用户ID: <%= currentUserId %>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert alert-info">
                    <h4>暂无用户数据</h4>
                    <p>系统中还没有用户，或者搜索结果为空。</p>
                    <p>请通知用户注册账号。</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="../footer.jsp"/>

<script>
    $(document).ready(function() {
        // 删除用户
        $(document).on('click', '.delete-user', function() {
            var userId = $(this).data('id');
            var username = $(this).data('username');
            var currentUserId = <%= currentUserId != null ? currentUserId : "null" %>;

            // 再次确认
            if (!confirm('确定要删除用户【' + username + '】吗？此操作不可恢复！')) {
                return;
            }

            // 发送删除请求
            $.ajax({
                url: '${pageContext.request.contextPath}/user/delete/' + userId,
                type: 'GET',
                dataType: 'json',
                success: function(result) {
                    if (result.success) {
                        alert(result.message);
                        // 刷新页面
                        location.reload();
                    } else {
                        alert(result.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('删除失败: ' + error);
                }
            });
        });

        // 重置密码
        $(document).on('click', '.reset-password', function() {
            var userId = $(this).data('id');
            var username = $(this).data('username');

            if (confirm('确定要重置用户【' + username + '】的密码吗？\n密码将重置为：123456\n\n注意：请访问编辑页面操作重置密码功能。')) {
                // 跳转到编辑页面
                window.location.href = '${pageContext.request.contextPath}/user/edit/' + userId;
            }
        });

        // 显示当前用户信息
        console.log('当前用户ID:', <%= currentUserId != null ? currentUserId : "未登录" %>);
    });
</script>
</body>
</html>
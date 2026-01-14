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
    <title>借阅管理</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .status-borrowed { color: #337ab7; }
        .status-returned { color: #5cb85c; }
        .status-overdue { color: #d9534f; font-weight: bold; }
        .no-records { padding: 40px; text-align: center; }
        .debug-info {
            display: none; /* 调试时改为block */
            background: #f0f0f0;
            padding: 10px;
            margin: 10px 0;
            border-radius: 5px;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="borrow"/>
</jsp:include>

<div class="container">
    <h2>借阅管理</h2>

    <!-- 调试信息 -->
    <div class="debug-info">
        用户角色: ${sessionScope.role} | 用户ID: ${sessionScope.userId} |
        记录数量: ${records != null ? records.size() : 0}
    </div>

    <!-- 提示信息 -->
    <c:if test="${not empty infoMessage}">
        <div class="alert alert-info">
                ${infoMessage}
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger">
                ${errorMessage}
        </div>
    </c:if>

    <!-- 操作按钮 -->
    <div style="margin-bottom: 15px;">
        <!-- 只有普通用户可以借阅图书 -->
        <c:if test="${sessionScope.role == 'USER'}">
            <a href="${pageContext.request.contextPath}/borrow/add" class="btn btn-primary">
                <span class="glyphicon glyphicon-plus"></span> 借阅图书
            </a>
        </c:if>
    </div>

    <!-- 借阅记录表格 -->
    <c:choose>
        <c:when test="${not empty records && !records.isEmpty()}">
            <table class="table table-bordered table-hover">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>图书名称</th>
                    <th>借阅人</th>
                    <th>借阅日期</th>
                    <th>应还日期</th>
                    <th>归还日期</th>
                    <th>状态</th>
                    <th>操作</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${records}" var="record">
                    <tr>
                        <td>${record.id}</td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty record.book}">
                                    ${record.book.title}
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">图书ID: ${record.bookId}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty record.user}">
                                    ${record.user.username}
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">用户ID: ${record.userId}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <fmt:formatDate value="${record.borrowDate}" pattern="yyyy-MM-dd"/>
                        </td>
                        <td>
                            <fmt:formatDate value="${record.dueDate}" pattern="yyyy-MM-dd"/>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty record.returnDate}">
                                    <fmt:formatDate value="${record.returnDate}" pattern="yyyy-MM-dd"/>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">未归还</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${record.status == 'BORROWED'}">
                                    <span class="status-borrowed">借阅中</span>
                                </c:when>
                                <c:when test="${record.status == 'RETURNED'}">
                                    <span class="status-returned">已归还</span>
                                </c:when>
                                <c:when test="${record.status == 'OVERDUE'}">
                                    <span class="status-overdue">逾期</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="label label-default">${record.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <!-- 详情按钮 -->
                            <a href="${pageContext.request.contextPath}/borrow/detail/${record.id}"
                               class="btn btn-info btn-xs">详情</a>

                            <!-- 还书按钮 - 只有借阅中的记录可以还书 -->
                            <c:if test="${record.status == 'BORROWED'}">
                                <a href="${pageContext.request.contextPath}/borrow/return/${record.id}"
                                   class="btn btn-success btn-xs"
                                   onclick="return confirm('确定要归还这本书吗？')">还书</a>
                                <a href="${pageContext.request.contextPath}/borrow/renew/${record.id}"
                                   class="btn btn-warning btn-xs">续借</a>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>

            <!-- 显示记录数量 -->
            <div class="text-muted">
                共 ${records.size()} 条记录
            </div>
        </c:when>
        <c:otherwise>
            <div class="no-records">
                <div class="well">
                    <h4>暂无借阅记录</h4>
                    <c:if test="${sessionScope.role == 'USER'}">
                        <p>您还没有借阅任何图书。</p>
                        <a href="${pageContext.request.contextPath}/book/list" class="btn btn-primary">
                            去借阅图书
                        </a>
                    </c:if>
                    <c:if test="${sessionScope.role == 'ADMIN'}">
                        <p>系统中还没有借阅记录。</p>
                        <p>请通知用户借阅图书。</p>
                    </c:if>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../footer.jsp"/>

<script>
    $(document).ready(function() {
        console.log('借阅记录数量:', ${records != null ? records.size() : 0});
        console.log('当前用户角色:', '${sessionScope.role}');
        console.log('当前用户ID:', '${sessionScope.userId}');

        // 调试：打印所有记录信息
        <c:forEach items="${records}" var="record" varStatus="status">
        console.log('记录${status.index + 1}: ID=${record.id}, 状态=${record.status}, 用户=${record.userId}, 图书=${record.bookId}');
        </c:forEach>

        // 如果没有记录，检查是否有错误
        <c:if test="${empty records}">
        console.log('没有借阅记录，可能是：');
        console.log('1. 用户从未借阅图书');
        console.log('2. 数据库中没有记录');
        console.log('3. 查询条件不正确');
        </c:if>
    });
</script>
</body>
</html>
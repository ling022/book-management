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
    <title>借阅记录详情</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .overdue {
            color: #dc3545;
            font-weight: bold;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="borrow"/>
</jsp:include>

<div class="container">
    <h2>借阅记录详情</h2>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">借阅记录 #${record.id}</h3>
        </div>
        <div class="panel-body">
            <div class="row">
                <div class="col-md-6">
                    <h4>图书信息</h4>
                    <table class="table table-bordered">
                        <tr>
                            <th width="40%">书名</th>
                            <td>${record.book.title}</td>
                        </tr>
                        <tr>
                            <th>作者</th>
                            <td>${record.book.author}</td>
                        </tr>
                        <tr>
                            <th>ISBN</th>
                            <td>${record.book.isbn}</td>
                        </tr>
                    </table>
                </div>

                <div class="col-md-6">
                    <h4>借阅信息</h4>
                    <table class="table table-bordered">
                        <tr>
                            <th width="40%">借阅人</th>
                            <td>${record.user.username}</td>
                        </tr>
                        <tr>
                            <th>借阅日期</th>
                            <td><fmt:formatDate value="${record.borrowDate}" pattern="yyyy年MM月dd日"/></td>
                        </tr>
                        <tr>
                            <th>应还日期</th>
                            <td class="${isOverdue ? 'overdue' : ''}">
                                <fmt:formatDate value="${record.dueDate}" pattern="yyyy年MM月dd日"/>
                                <c:if test="${isOverdue}"> (已逾期)</c:if>
                            </td>
                        </tr>
                        <tr>
                            <th>归还日期</th>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty record.returnDate}">
                                        <fmt:formatDate value="${record.returnDate}" pattern="yyyy年MM月dd日"/>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">尚未归还</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>状态</th>
                            <td>
                                <c:choose>
                                    <c:when test="${record.status == 'BORROWED'}">
                                        <span class="label label-primary">借阅中</span>
                                    </c:when>
                                    <c:when test="${record.status == 'RETURNED'}">
                                        <span class="label label-success">已归还</span>
                                    </c:when>
                                    <c:when test="${record.status == 'OVERDUE'}">
                                        <span class="label label-danger">已逾期</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="label label-default">${record.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="pull-right">
                        <c:if test="${record.status == 'BORROWED'}">
                            <a href="${pageContext.request.contextPath}/borrow/return/${record.id}"
                               class="btn btn-success"
                               onclick="return confirm('确认要归还这本书吗？')">归还</a>
                            <a href="${pageContext.request.contextPath}/borrow/renew/${record.id}?additionalDays=15"
                               class="btn btn-warning"
                               onclick="return confirm('确认要续借15天吗？')">续借15天</a>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/borrow/list" class="btn btn-default">返回列表</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp"/>
</body>
</html>
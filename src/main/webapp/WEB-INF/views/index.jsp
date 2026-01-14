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
    <title>图书管理系统 - 首页</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        body {
            padding-top: 50px;
            background-color: #f8f9fa;
        }
        .jumbotron {
            background-color: white;
            border: 1px solid #e7e7e7;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .feature-box {
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background: white;
            margin-bottom: 20px;
            transition: all 0.3s;
        }
        .feature-box:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .feature-icon {
            font-size: 40px;
            color: #337ab7;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
<jsp:include page="common.jsp">
    <jsp:param name="page" value="index"/>
</jsp:include>

<div class="container">
    <div class="jumbotron text-center">
        <h1>欢迎使用图书管理系统</h1>
        <p>基于SSM框架开发的图书管理系统，提供完善的图书管理、借阅管理、用户管理等功能</p>
        <p>
            <c:if test="${empty sessionScope.user}">
                <a class="btn btn-primary btn-lg" href="${pageContext.request.contextPath}/user/login" role="button">
                    立即登录
                </a>
                <a class="btn btn-success btn-lg" href="${pageContext.request.contextPath}/user/register" role="button">
                    注册账号
                </a>
            </c:if>
            <c:if test="${not empty sessionScope.user}">
                <c:choose>
                    <c:when test="${sessionScope.role == 'ADMIN'}">
                        <a class="btn btn-primary btn-lg" href="${pageContext.request.contextPath}/book/list" role="button">
                            图书管理
                        </a>
                        <a class="btn btn-success btn-lg" href="${pageContext.request.contextPath}/borrow/list" role="button">
                            借阅管理
                        </a>
                        <a class="btn btn-info btn-lg" href="${pageContext.request.contextPath}/user/list" role="button">
                            用户管理
                        </a>
                    </c:when>
                    <c:when test="${sessionScope.role == 'USER'}">
                        <a class="btn btn-primary btn-lg" href="${pageContext.request.contextPath}/book/list" role="button">
                            查看图书
                        </a>
                        <a class="btn btn-success btn-lg" href="${pageContext.request.contextPath}/borrow/list" role="button">
                            我的借阅
                        </a>
                    </c:when>
                </c:choose>
            </c:if>
        </p>
    </div>
</div>

<jsp:include page="footer.jsp"/>

<script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/bootstrap.min.js"></script>
<script>
    $(document).ready(function() {
        // 自动关闭警告框
        setTimeout(function() {
            $('.alert').alert('close');
        }, 5000);
    });
    $(function() {
        // 预加载常用页面
        setTimeout(function() {
            var urls = [
                '/book/list?ajax=true',
                '/borrow/list?ajax=true',
                '/user/list?ajax=true'
            ];

            urls.forEach(function(url) {
                $.get(url, function(data) {
                    localStorage.setItem('cached_' + url, data);
                });
            });
        }, 1000); // 延迟1秒加载，不影响首页显示
    });
</script>
</body>
</html>
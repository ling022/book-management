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
    <title>错误页面</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .error-container {
            text-align: center;
            padding: 100px 20px;
        }
        .error-code {
            font-size: 120px;
            font-weight: bold;
            color: #d9534f;
        }
        .error-message {
            font-size: 24px;
            margin: 20px 0;
        }
        .error-description {
            color: #666;
            margin-bottom: 30px;
        }
        .error-details {
            margin-top: 30px;
            padding: 20px;
            background-color: #f8f9fa;
            border: 1px solid #e7e7e7;
            border-radius: 5px;
            text-align: left;
        }
    </style>
</head>
<body>
<jsp:include page="common.jsp">
    <jsp:param name="page" value="error"/>
</jsp:include>

<div class="container">
    <div class="error-container">
        <div class="error-code">
            <c:choose>
                <c:when test="${not empty pageContext.errorData.statusCode}">
                    ${pageContext.errorData.statusCode}
                </c:when>
                <c:otherwise>
                    错误
                </c:otherwise>
            </c:choose>
        </div>

        <div class="error-message">
            <c:choose>
                <c:when test="${pageContext.errorData.statusCode == 404}">
                    页面未找到
                </c:when>
                <c:when test="${pageContext.errorData.statusCode == 500}">
                    服务器内部错误
                </c:when>
                <c:otherwise>
                    系统错误
                </c:otherwise>
            </c:choose>
        </div>

        <div class="error-description">
            <c:choose>
                <c:when test="${pageContext.errorData.statusCode == 404}">
                    抱歉，您访问的页面不存在或已被移除。
                </c:when>
                <c:when test="${pageContext.errorData.statusCode == 500}">
                    抱歉，服务器出现了问题，请稍后再试。
                </c:when>
                <c:otherwise>
                    抱歉，系统出现了未知错误。
                </c:otherwise>
            </c:choose>
        </div>

        <div>
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">返回首页</a>
            <a href="javascript:history.back()" class="btn btn-default">返回上一页</a>
        </div>

        <!-- 开发环境下显示错误详情 -->
        <c:if test="${pageContext.errorData.throwable != null}">
            <div class="error-details" style="display: none;" id="errorDetails">
                <h4>错误详情（仅开发环境可见）</h4>
                <p><strong>错误信息：</strong> ${pageContext.errorData.throwable.message}</p>
                <p><strong>异常类型：</strong> ${pageContext.errorData.throwable.class.name}</p>
                <h5>堆栈跟踪：</h5>
                <pre><c:forEach items="${pageContext.errorData.throwable.stackTrace}" var="trace">
                    ${trace}</c:forEach></pre>
            </div>

            <button class="btn btn-link" onclick="toggleErrorDetails()">显示/隐藏错误详情</button>
        </c:if>
    </div>
</div>

<jsp:include page="footer.jsp"/>

<script>
    function toggleErrorDetails() {
        var details = document.getElementById('errorDetails');
        if (details.style.display === 'none') {
            details.style.display = 'block';
        } else {
            details.style.display = 'none';
        }
    }
</script>
</body>
</html>
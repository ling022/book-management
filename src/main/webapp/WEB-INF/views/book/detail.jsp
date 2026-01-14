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
    <title>图书详情 - ${book.title}</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .book-detail-container {
            max-width: 1000px;
            margin: 0 auto;
        }
        .book-cover-section {
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            text-align: center;
        }
        .book-cover-large {
            max-width: 300px;
            max-height: 400px;
            border: 2px solid #ddd;
            border-radius: 6px;
            padding: 5px;
            background: #fff;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 15px;
        }
        .no-cover-large {
            width: 300px;
            height: 400px;
            border: 2px dashed #ccc;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #999;
            font-size: 16px;
            border-radius: 6px;
            background: #f9f9f9;
            margin: 0 auto 15px;
        }
        .book-info-section {
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .info-row {
            display: flex;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #f0f0f0;
        }
        .info-label {
            width: 120px;
            font-weight: 600;
            color: #555;
            flex-shrink: 0;
        }
        .info-value {
            flex: 1;
            color: #333;
        }
        .info-value .label {
            font-size: 12px;
            padding: 4px 8px;
            margin-left: 5px;
        }
        .book-description {
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .book-description h4 {
            color: #333;
            border-bottom: 2px solid #28a745;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .description-content {
            line-height: 1.6;
            color: #555;
            font-size: 14px;
            white-space: pre-line;
        }
        .action-buttons {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .stock-info {
            font-size: 16px;
            font-weight: 600;
        }
        .available {
            color: #28a745;
        }
        .unavailable {
            color: #dc3545;
        }
        .status-available {
            background-color: #28a745;
        }
        .status-borrowed {
            background-color: #dc3545;
        }
        .status-maintenance {
            background-color: #6c757d;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="book"/>
</jsp:include>

<div class="container book-detail-container">
    <h2>图书详情</h2>

    <!-- 图书封面 -->
    <div class="book-cover-section">
        <h3>${book.title}</h3>
        <c:choose>
            <c:when test="${not empty book.imagePath}">
                <img src="${pageContext.request.contextPath}${book.imagePath}"
                     alt="${book.title}"
                     class="book-cover-large"
                     onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/static/images/no-cover.png'">
            </c:when>
            <c:otherwise>
                <div class="no-cover-large">
                    <span>暂无封面</span>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- 库存状态 -->
        <div class="stock-info">
            <c:choose>
                <c:when test="${book.availableCopies > 0}">
                    <span class="available">
                        可借 ${book.availableCopies}/${book.totalCopies} 册
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="unavailable">
                        已全部借出 0/${book.totalCopies} 册
                    </span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="book-info-section">
                <h4>基本信息</h4>

                <div class="info-row">
                    <div class="info-label">书名</div>
                    <div class="info-value">${book.title}</div>
                </div>

                <div class="info-row">
                    <div class="info-label">作者</div>
                    <div class="info-value">${book.author}</div>
                </div>

                <div class="info-row">
                    <div class="info-label">ISBN</div>
                    <div class="info-value">${book.isbn}</div>
                </div>

                <div class="info-row">
                    <div class="info-label">出版社</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty book.publisher}">
                                ${book.publisher}
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted">未设置</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-label">出版日期</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty book.publishDate}">
                                <fmt:formatDate value="${book.publishDate}" pattern="yyyy年MM月dd日"/>
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted">未设置</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-label">分类</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty book.category}">
                                ${book.category}
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted">未分类</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="book-info-section">
                <h4>库存信息</h4>

                <div class="info-row">
                    <div class="info-label">总册数</div>
                    <div class="info-value">${book.totalCopies} 册</div>
                </div>

                <div class="info-row">
                    <div class="info-label">可借册数</div>
                    <div class="info-value">
                        ${book.availableCopies} 册
                        <c:choose>
                            <c:when test="${book.availableCopies > 0}">
                                <span class="label label-success">可借</span>
                            </c:when>
                            <c:otherwise>
                                <span class="label label-danger">已借完</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-label">状态</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${book.status == 'AVAILABLE'}">
                                <span class="label status-available">可借</span>
                            </c:when>
                            <c:when test="${book.status == 'BORROWED'}">
                                <span class="label status-borrowed">已借出</span>
                            </c:when>
                            <c:when test="${book.status == 'MAINTENANCE'}">
                                <span class="label status-maintenance">维护中</span>
                            </c:when>
                            <c:otherwise>
                                <span class="label label-default">${book.status}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-label">添加时间</div>
                    <div class="info-value">
                        <fmt:formatDate value="${book.createdTime}" pattern="yyyy-MM-dd HH:mm:ss"/>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-label">最后更新</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty book.createdTime}">
                                <fmt:formatDate value="${book.createdTime}" pattern="yyyy-MM-dd HH:mm:ss"/>
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted">未知</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 图书描述 -->
    <div class="book-description">
        <h4>图书描述</h4>
        <div class="description-content">
            <c:choose>
                <c:when test="${not empty book.description}">
                    ${book.description}
                </c:when>
                <c:otherwise>
                    <div class="text-center text-muted" style="padding: 30px;">
                        <span class="glyphicon glyphicon-info-sign" style="font-size: 48px; margin-bottom: 15px;"></span>
                        <p>暂无描述</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- 操作按钮 -->
    <div class="action-buttons">
        <a href="${pageContext.request.contextPath}/book/list" class="btn btn-default btn-lg">
            <span class="glyphicon glyphicon-arrow-left"></span> 返回列表
        </a>

        <!-- 编辑按钮 - 仅管理员可见 -->
        <c:if test="${isAdmin}">
            <a href="${pageContext.request.contextPath}/book/edit/${book.id}"
               class="btn btn-warning btn-lg">
                <span class="glyphicon glyphicon-edit"></span> 编辑图书
            </a>

            <a href="javascript:void(0);"
               class="btn btn-danger btn-lg delete-book-detail"
               data-id="${book.id}"
               data-title="${book.title}">
                <span class="glyphicon glyphicon-trash"></span> 删除图书
            </a>
        </c:if>

        <!-- 借阅按钮 - 仅普通用户可见，且图书可借 -->
        <c:if test="${book.availableCopies > 0 && isUser}">
            <c:choose>
                <c:when test="${book.status == 'MAINTENANCE'}">
                    <!-- 维护中的图书 -->
                    <button class="btn btn-secondary btn-lg" disabled>
                        <span class="glyphicon glyphicon-wrench"></span> 维护中
                    </button>
                    <div class="text-muted" style="margin-top: 10px; font-size: 14px;">
                        <span class="glyphicon glyphicon-info-sign"></span>
                        该图书正在进行维护，暂时无法借阅
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- 正常可借的图书 -->
                    <a href="${pageContext.request.contextPath}/borrow/add?bookId=${book.id}"
                       class="btn btn-success btn-lg">
                        <span class="glyphicon glyphicon-book"></span> 借阅此书
                    </a>
                </c:otherwise>
            </c:choose>
        </c:if>

        <!-- 如果不可借，显示原因 -->
        <c:if test="${book.availableCopies == 0 && isUser}">
            <button class="btn btn-secondary btn-lg" disabled>
                <span class="glyphicon glyphicon-ban-circle"></span> 暂无库存
            </button>
            <div class="text-muted" style="margin-top: 10px; font-size: 14px;">
                <span class="glyphicon glyphicon-info-sign"></span>
                该图书已全部借出，请等待归还
            </div>
        </c:if>

        <!-- 管理员查看时显示维护状态提示 -->
        <c:if test="${isAdmin && book.status == 'MAINTENANCE'}">
            <div class="alert alert-warning" style="margin-top: 15px; max-width: 300px; margin-left: auto; margin-right: auto;">
                <span class="glyphicon glyphicon-exclamation-sign"></span>
                该图书状态为：<strong>维护中</strong><br>
                普通用户无法借阅维护中的图书
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="../footer.jsp"/>

<script>
    $(document).ready(function() {
        // 图片加载失败处理
        $('.book-cover-large').on('error', function() {
            $(this).attr('src', '${pageContext.request.contextPath}/static/images/no-cover.png');
        });

        // 删除图书
        $('.delete-book-detail').click(function() {
            var bookId = $(this).data('id');
            var bookTitle = $(this).data('title');

            if (confirm('确定要删除《' + bookTitle + '》吗？删除后将无法恢复！')) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/book/delete/' + bookId,
                    type: 'GET',
                    dataType: 'json',
                    success: function(result) {
                        if (result.success) {
                            alert(result.successMessage);
                            // 跳转到图书列表
                            window.location.href = '${pageContext.request.contextPath}/book/list';
                        } else {
                            alert(result.errorMessage);
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('删除失败: ' + error);
                    }
                });
            }
        });

        // 自动隐藏消息提示
        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 3000);
    });
</script>
</body>
</html>
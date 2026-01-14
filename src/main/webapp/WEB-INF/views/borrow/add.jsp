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
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>借阅图书 - 图书管理系统</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .borrow-form-container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .form-hint {
            font-size: 13px;
            color: #6c757d;
            margin-top: 5px;
        }
        .book-option {
            padding: 8px;
            border-bottom: 1px solid #eee;
        }
        .book-option:last-child {
            border-bottom: none;
        }
        .available-count {
            color: #28a745;
            font-weight: bold;
        }
        .unavailable {
            color: #dc3545;
        }
        .borrow-notice {
            background-color: #f8f9fa;
            border-left: 4px solid #17a2b8;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .borrow-notice h5 {
            margin-top: 0;
            color: #138496;
        }
        .borrow-notice ul {
            margin-bottom: 0;
            padding-left: 20px;
        }
        .direct-message {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="borrow"/>
</jsp:include>

<div class="container">
    <h2>借阅图书</h2>

    <!-- 直接显示的消息（不在右上角显示） -->
    <c:if test="${not empty errorMessage and showDirectly}">
        <div class="direct-message">
            <span class="glyphicon glyphicon-exclamation-sign"></span>
            <strong>提示：</strong> ${errorMessage}
        </div>
    </c:if>

    <!-- 权限检查 -->
    <c:if test="${sessionScope.role != 'USER'}">
        <div class="direct-message">
            <span class="glyphicon glyphicon-exclamation-sign"></span>
            <strong>权限不足！</strong> 只有普通用户可以借阅图书。
        </div>
        <a href="${pageContext.request.contextPath}/book/list" class="btn btn-default">
            <span class="glyphicon glyphicon-arrow-left"></span> 返回图书列表
        </a>
    </c:if>

    <!-- 需要跳转登录 -->
    <c:if test="${needRedirect}">
        <div class="direct-message">
            <span class="glyphicon glyphicon-exclamation-sign"></span>
            <strong>提示：</strong> 请先登录！
        </div>
        <a href="${pageContext.request.contextPath}/user/login" class="btn btn-primary">
            <span class="glyphicon glyphicon-log-in"></span> 前往登录
        </a>
    </c:if>

    <c:if test="${sessionScope.role == 'USER' and not needRedirect}">
        <div class="panel panel-default borrow-form-container">
            <div class="panel-heading">
                <h3 class="panel-title">选择图书</h3>
            </div>
            <div class="panel-body">
                <!-- 借阅须知 - 永远不会消失 -->
                <div class="borrow-notice">
                    <h5><span class="glyphicon glyphicon-info-sign"></span> 借阅须知</h5>
                    <c:choose>
                        <c:when test="${not empty borrowNotice}">
                            <h5>${borrowNotice.title}</h5>
                            <pre style="background: transparent; border: none; padding: 0; margin: 0; font-family: inherit; white-space: pre-line;">${borrowNotice.content}</pre>
                        </c:when>
                        <c:otherwise>
                            <ul>
                                <li>借阅到期前可以续借一次</li>
                                <li>逾期未还将产生逾期记录</li>
                                <li>请妥善保管所借图书</li>
                                <li>如有疑问请联系管理员</li>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- 如果通过bookId参数进入，自动选择该书 -->
                <form action="${pageContext.request.contextPath}/borrow/borrow" method="get">
                    <input type="hidden" name="preselected" id="preselected" value="false">

                    <div class="form-group">
                        <label for="bookId">
                            选择图书 <span class="text-danger">*</span>
                        </label>
                        <select class="form-control" id="bookId" name="bookId" required>
                            <option value="">-- 请选择图书 --</option>
                            <c:choose>
                                <c:when test="${not empty books}">
                                    <c:forEach items="${books}" var="book">
                                        <option value="${book.id}">
                                                ${book.title} - ${book.author}
                                            <span class="available-count">(可借: ${book.availableCopies}本)</span>
                                        </option>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <option value="" disabled>暂无可借图书</option>
                                </c:otherwise>
                            </c:choose>
                        </select>
                        <c:if test="${not empty infoMessage}">
                            <div class="alert alert-info">
                                <span class="glyphicon glyphicon-info-sign"></span>
                                    ${infoMessage}
                            </div>
                        </c:if>
                        <div class="form-hint">只显示有库存的图书</div>
                    </div>

                    <div class="form-group">
                        <label for="days">
                            借阅天数 <span class="text-danger">*</span>
                        </label>
                        <select class="form-control" id="days" name="days" required>
                            <option value="7">7天</option>
                            <option value="15" selected>15天</option>
                            <option value="30">30天</option>
                            <option value="60">60天</option>
                        </select>
                        <div class="form-hint">请根据需求选择合适的借阅天数</div>
                    </div>

                    <div class="form-group text-center">
                        <button type="submit" class="btn btn-primary btn-lg">
                            <span class="glyphicon glyphicon-ok"></span> 确认借阅
                        </button>
                        <a href="${pageContext.request.contextPath}/borrow/list" class="btn btn-default btn-lg">
                            <span class="glyphicon glyphicon-remove"></span> 取消
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </c:if>
</div>

<jsp:include page="../footer.jsp"/>

<script>
    $(document).ready(function() {
        console.log("=== 借书页面开始初始化 ===");

        // 从URL获取参数
        var urlParams = new URLSearchParams(window.location.search);
        var bookId = urlParams.get('bookId');
        var preselect = urlParams.get('preselect');
        var title = urlParams.get('title');

        console.log("URL参数:", {
            bookId: bookId,
            preselect: preselect,
            title: title,
            fullURL: window.location.href
        });

        // ====== 方法1：使用jQuery直接设置下拉框 ======
        function selectBookInDropdown(bookId) {
            console.log("尝试选择图书，ID:", bookId);

            // 方法1：直接设置值
            $('#bookId').val(bookId);

            // 检查是否设置成功
            var currentValue = $('#bookId').val();
            console.log("设置后下拉框值:", currentValue);

            if (currentValue === bookId) {
                console.log("✅ 下拉框设置成功");
                return true;
            } else {
                console.warn("⚠ 下拉框设置失败，尝试方法2");
                return false;
            }
        }

        // ====== 方法2：遍历选项找到匹配的 ======
        function findAndSelectBook(bookId) {
            console.log("遍历下拉框选项寻找图书ID:", bookId);

            var found = false;
            var optionText = "";

            $('#bookId option').each(function() {
                var optionValue = $(this).val();
                var optionText = $(this).text();

                console.log("选项:", optionValue, "-", optionText);

                if (optionValue === bookId) {
                    console.log("✅ 找到匹配选项:", optionValue);
                    $(this).prop('selected', true);
                    found = true;
                    return false; // 退出循环
                }
            });

            return found;
        }

        // ====== 方法3：强制触发change事件 ======
        function forceSelectBook(bookId) {
            console.log("强制选择图书:", bookId);

            // 先清空
            $('#bookId').val('');

            // 设置新值
            $('#bookId').val(bookId);

            // 手动触发change事件
            $('#bookId').trigger('change');
            $('#bookId').trigger('chosen:updated'); // 如果有chosen插件

            console.log("强制设置后值:", $('#bookId').val());

            return $('#bookId').val() === bookId;
        }

        // ====== 执行预选逻辑 ======
        function preselectBook(bookId) {
            console.log("开始预选图书流程...");

            // 显示加载状态
            $('#bookId').css({
                'border': '2px solid #ffc107',
                'background-color': '#fff3cd'
            });

            var success = false;

            // 尝试方法1
            if (!success) {
                success = selectBookInDropdown(bookId);
            }

            // 尝试方法2
            if (!success) {
                success = findAndSelectBook(bookId);
            }

            // 尝试方法3
            if (!success) {
                success = forceSelectBook(bookId);
            }

            if (success) {
                console.log("🎉 预选成功！");

                // 添加预选标记
                $('label[for="bookId"]').append(
                    '<span class="label label-success" style="margin-left:10px;">' +
                    '<span class="glyphicon glyphicon-ok"></span> 已预选' +
                    '</span>'
                );

                // 高亮显示
                $('#bookId').css({
                    'border': '2px solid #28a745',
                    'background-color': '#d4edda'
                });

                // 显示成功消息
                showMessage('success', '已为您预选图书，请确认借阅天数');

                // 自动检查库存
                setTimeout(function() {
                    checkBookAvailability(bookId);
                }, 500);

                return true;
            } else {
                console.error("❌ 所有预选方法都失败了");

                // 显示错误消息
                showMessage('warning',
                    title ? '无法预选《' + decodeURIComponent(title) + '》，请从列表中选择' :
                        '预选失败，请手动选择图书');

                return false;
            }
        }

        // ====== 检查库存函数 ======
        function checkBookAvailability(bookId) {
            if (!bookId) return;

            console.log("检查图书可用性:", bookId);

            $.ajax({
                url: '${pageContext.request.contextPath}/borrow/checkAvailability/' + bookId,
                type: 'GET',
                success: function(result) {
                    console.log("库存检查结果:", result);

                    if (result.available) {
                        showMessage('success',
                            '✓ 该书可借' +
                            (result.availableCopies ? '，剩余 ' + result.availableCopies + ' 本' : ''));
                    } else {
                        showMessage('warning', '⚠ ' + (result.message || '该书暂时不可借'));
                    }
                },
                error: function() {
                    console.error("库存检查失败");
                }
            });
        }

        // ====== 消息显示函数 ======
        function showMessage(type, message) {
            // 移除旧消息
            $('.preselect-message').remove();

            var icon = '';
            switch(type) {
                case 'success': icon = 'glyphicon-ok-sign'; break;
                case 'warning': icon = 'glyphicon-warning-sign'; break;
                case 'error': icon = 'glyphicon-remove-sign'; break;
                default: icon = 'glyphicon-info-sign';
            }

            var messageHtml =
                '<div class="alert alert-' + type + ' preselect-message" style="margin-top:15px;">' +
                '   <span class="glyphicon ' + icon + '"></span> ' +
                '   ' + message +
                '</div>';

            $('.borrow-notice').after(messageHtml);

            // 自动消失
            if (type !== 'error') {
                setTimeout(function() {
                    $('.preselect-message').fadeOut(300, function() {
                        $(this).remove();
                    });
                }, 5000);
            }
        }

        // ====== 初始化执行 ======
        setTimeout(function() {
            if (bookId && (preselect === 'true' || preselect === true)) {
                console.log("执行预选逻辑...");
                preselectBook(bookId);
            } else if (bookId) {
                console.log("有bookId但没有preselect参数，尝试选择");
                selectBookInDropdown(bookId);
            }

            // 打印下拉框所有选项用于调试
            console.log("=== 下拉框选项列表 ===");
            $('#bookId option').each(function(index) {
                console.log(index + ": value='" + $(this).val() + "', text='" + $(this).text() + "'");
            });
            console.log("=== 选项列表结束 ===");

        }, 100); // 稍微延迟确保DOM加载完成

        // ====== 下拉框改变事件 ======
        $('#bookId').change(function() {
            var selectedValue = $(this).val();
            console.log("用户改变选择:", selectedValue);

            // 移除预选标记
            $('label[for="bookId"] .label').remove();

            // 重置样式
            $(this).css({
                'border': '',
                'background-color': ''
            });

            // 检查新选图书
            if (selectedValue) {
                checkBookAvailability(selectedValue);
            }
        });

        // ====== 表单提交验证 ======
        $('form').submit(function(e) {
            var bookId = $('#bookId').val();

            if (!bookId) {
                e.preventDefault();
                alert('请选择要借阅的图书！');
                return false;
            }

            console.log("表单提交，图书ID:", bookId);
            return true;
        });

        console.log("=== 借书页面初始化完成 ===");
    });
</script>
</body>
</html>
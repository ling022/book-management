<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户注册</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .register-container {
            max-width: 400px;
            margin: 50px auto;
            padding: 30px;
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .register-header {
            text-align: center;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="register"/>
</jsp:include>

<div class="container">
    <div class="register-container">
        <div class="register-header">
            <h2>用户注册</h2>
        </div>

        <!-- 显示错误信息 -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${errorMessage}
            </div>
        </c:if>

        <!-- 显示成功信息 -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${successMessage}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/user/register" method="post">
            <div class="form-group">
                <label for="username">用户名 *</label>
                <input type="text" class="form-control" id="username" name="username"
                       value="${user.username}" placeholder="请输入用户名" required maxlength="20" minlength="3">
                <small class="form-text text-muted">用户名长度3-20个字符</small>
            </div>

            <div class="form-group">
                <label for="password">密码 *</label>
                <input type="password" class="form-control" id="password" name="password"
                       placeholder="请输入密码" required minlength="6">
                <small class="form-text text-muted">密码长度至少6位</small>
            </div>

            <div class="form-group">
                <label for="confirmPassword">确认密码 *</label>
                <input type="password" class="form-control" id="confirmPassword"
                       placeholder="请再次输入密码" required minlength="6">
                <small class="form-text text-muted">请再次输入密码</small>
            </div>

            <div class="form-group">
                <label for="email">邮箱</label>
                <input type="email" class="form-control" id="email" name="email"
                       value="${user.email}" placeholder="请输入邮箱">
            </div>

            <div class="form-group">
                <label for="phone">电话</label>
                <input type="tel" class="form-control" id="phone" name="phone"
                       value="${user.phone}" placeholder="请输入电话">
            </div>

            <div class="form-group">
                <button type="submit" class="btn btn-primary btn-block">
                    注册
                </button>
            </div>

            <div class="text-center">
                已有账号？ <a href="${pageContext.request.contextPath}/user/login">立即登录</a>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../footer.jsp"/>

<script>
    $(document).ready(function() {
        // 立即隐藏所有消息框
        $('#messageContainer').hide();
        $('.alert-message').hide();
        $('.alert').hide();

        // 或者直接移除
        $('#messageContainer').empty();
        // 表单验证
        $('form').submit(function(e) {
            var password = $('#password').val();
            var confirmPassword = $('#confirmPassword').val();

            // 验证密码是否一致
            if (password !== confirmPassword) {
                e.preventDefault();
                alert('两次输入的密码不一致！');
                $('#confirmPassword').focus();
                return false;
            }

            // 验证密码长度
            if (password.length < 6) {
                e.preventDefault();
                alert('密码长度至少为6位！');
                $('#password').focus();
                return false;
            }

            // 验证用户名长度
            var username = $('#username').val().trim();
            if (username.length < 3 || username.length > 20) {
                e.preventDefault();
                alert('用户名长度应在3-20个字符之间！');
                $('#username').focus();
                return false;
            }

            return true;
        });

        // 自动关闭警告框
        setTimeout(function() {
            $('.alert').alert('close');
        }, 5000);
    });
    // 在页面完全加载前就隐藏
    $(window).on('load', function() {
        $('#messageContainer').hide();
    });
</script>
</body>
</html>
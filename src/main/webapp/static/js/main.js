// 全局JavaScript函数

// 显示加载动画
function showLoading(element) {
    $(element).html('<div class="loading"></div>');
}

// 隐藏加载动画
function hideLoading(element, originalContent) {
    $(element).html(originalContent);
}

// 显示消息提示
function showMessage(type, message, duration) {
    var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
    var alertHtml = '<div class="alert ' + alertClass + ' alert-dismissible fade in">' +
        '<button type="button" class="close" data-dismiss="alert">&times;</button>' +
        message +
        '</div>';

    $('#messageContainer').html(alertHtml);

    if (duration) {
        setTimeout(function() {
            $('.alert').alert('close');
        }, duration);
    }
}

// 表单验证
function validateForm(formId, rules) {
    var form = $('#' + formId);
    var isValid = true;

    $.each(rules, function(field, rule) {
        var fieldElement = form.find('[name="' + field + '"]');
        var value = fieldElement.val().trim();

        if (rule.required && !value) {
            showFieldError(fieldElement, rule.message || '此字段不能为空');
            isValid = false;
        } else if (rule.pattern && !rule.pattern.test(value)) {
            showFieldError(fieldElement, rule.message || '格式不正确');
            isValid = false;
        } else {
            clearFieldError(fieldElement);
        }
    });

    return isValid;
}

function showFieldError(element, message) {
    var parent = element.parent();
    parent.addClass('has-error');

    var errorElement = parent.find('.help-block');
    if (errorElement.length === 0) {
        parent.append('<span class="help-block">' + message + '</span>');
    } else {
        errorElement.text(message);
    }
}

function clearFieldError(element) {
    var parent = element.parent();
    parent.removeClass('has-error');
    parent.find('.help-block').remove();
}

// AJAX表单提交
function submitFormAjax(formId, successCallback, errorCallback) {
    var form = $('#' + formId);
    var formData = form.serialize();
    var url = form.attr('action');
    var method = form.attr('method') || 'POST';

    showLoading(form.find('button[type="submit"]'));

    $.ajax({
        url: url,
        type: method,
        data: formData,
        success: function(response) {
            if (successCallback) {
                successCallback(response);
            }
        },
        error: function(xhr, status, error) {
            if (errorCallback) {
                errorCallback(xhr, status, error);
            } else {
                showMessage('error', '请求失败: ' + error);
            }
        },
        complete: function() {
            hideLoading(form.find('button[type="submit"]'), form.find('button[type="submit"]').data('original-text'));
        }
    });
}

// 分页功能
function loadPage(page, pageSize, callback) {
    $.ajax({
        url: currentPageUrl,
        type: 'GET',
        data: { page: page, pageSize: pageSize },
        success: function(data) {
            if (callback) {
                callback(data);
            }
        }
    });
}

// 搜索功能
function search(keyword, callback) {
    $.ajax({
        url: searchUrl,
        type: 'GET',
        data: { keyword: keyword },
        success: function(data) {
            if (callback) {
                callback(data);
            }
        }
    });
}

// 日期格式化
function formatDate(date, format) {
    if (!date) return '';

    var d = new Date(date);
    var map = {
        'yyyy': d.getFullYear(),
        'MM': ('0' + (d.getMonth() + 1)).slice(-2),
        'dd': ('0' + d.getDate()).slice(-2),
        'HH': ('0' + d.getHours()).slice(-2),
        'mm': ('0' + d.getMinutes()).slice(-2),
        'ss': ('0' + d.getSeconds()).slice(-2)
    };

    return format.replace(/yyyy|MM|dd|HH|mm|ss/gi, function(matched) {
        return map[matched];
    });
}

// 防抖函数
function debounce(func, wait) {
    var timeout;
    return function() {
        var context = this;
        var args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(function() {
            func.apply(context, args);
        }, wait);
    };
}

// 节流函数
function throttle(func, limit) {
    var inThrottle;
    return function() {
        var context = this;
        var args = arguments;
        if (!inThrottle) {
            func.apply(context, args);
            inThrottle = true;
            setTimeout(function() {
                inThrottle = false;
            }, limit);
        }
    };
}

// 初始化函数
$(document).ready(function() {
    // 初始化工具提示
    $('[data-toggle="tooltip"]').tooltip();

    // 初始化弹出框
    $('[data-toggle="popover"]').popover();

    // 自动关闭警告框
    setTimeout(function() {
        $('.alert:not(.alert-permanent)').alert('close');
    }, 5000);

    // 回车键提交表单
    $('form').on('keypress', function(e) {
        if (e.which === 13) {
            $(this).submit();
        }
    });

    // 保存按钮原始文本
    $('button[type="submit"]').each(function() {
        $(this).data('original-text', $(this).html());
    });
});
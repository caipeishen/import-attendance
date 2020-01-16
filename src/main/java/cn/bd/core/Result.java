package cn.bd.core;

import com.alibaba.fastjson.JSONArray;

/**
 * 统一API响应结果封装
 */
public class Result<T> {
    private Integer code;
    private String message;
    private T data;

    public Result setCode(ResultCode resultCode) {
        this.code = resultCode.code();
        return this;
    }

    public Integer getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public Result setMessage(String message) {
        this.message = message;
        return this;
    }

    public T getData() {
        return data;
    }

    public Result setData(T data) {
        this.data = data;
        return this;
    }

    @Override
    public String toString() {
        //return JSONArray.toJSONString(this);//不能处理日期问题
        //@JSONField可以处理FastJson的日期问题，JSONArray.toJSONStringWithDateFormat也可以
        return JSONArray.toJSONStringWithDateFormat(this,"yyyy-MM-dd HH:mm:ss");
    }
}

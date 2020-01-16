package cn.bd.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.metadata.BaseRowModel;
import com.alibaba.fastjson.annotation.JSONField;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

/**
 * @author _Cps
 * @create 2019-02-14 10:12
 * @desc 导出数据实体类
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ImportAttendance extends BaseRowModel { //BaseRowModel 阿里的Excel导入导出

    private String id;

    @ExcelProperty(value="员工工号",index=0)
    private String userNo;

    @ExcelProperty(value="员工姓名",index=1)
    private String userName;

    private String userSerial;

    // 解决后台到前台数据成数字状态
    @JSONField(format="yyyy-MM-dd HH:mm:ss")
    @ExcelProperty(value="开始时间",index=2)
    private Date beginDate;

    @JSONField(format="yyyy-MM-dd HH:mm:ss")
    @ExcelProperty(value="结束时间",index=3)
    private Date endDate;

    @JSONField(format="yyyy-MM-dd HH:mm:ss")
    @ExcelProperty(value="导入时间",index=4)
    private Date createDate;

    @ExcelProperty(value="工作状态",index=5)
    private String workStatus;

    @ExcelProperty(value="是否执行",index=6)
    private String isExec;


    // 查询参数
    private String searchName;
    private String startDate;
    private String finishDate;

    // 分页参数
    private Integer current;
    private Integer pageSize;

}

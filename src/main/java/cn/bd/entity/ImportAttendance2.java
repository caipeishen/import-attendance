package cn.bd.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.metadata.BaseRowModel;
import com.alibaba.fastjson.annotation.JSONField;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

/**
 * @author _Cps
 * @create 2019-02-14 10:12
 * @desc 导入数据模板实体类
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ImportAttendance2 extends BaseRowModel { //BaseRowModel 阿里的Excel导入导出

    @ExcelProperty(value="员工工号",index=0)
    private String userNo;

    @ExcelProperty(value="员工姓名",index=1)
    private String userName;

    @ExcelProperty(value="开始时间",index=2)
    private Date beginDate;

    @ExcelProperty(value="结束时间",index=3)
    private Date endDate;

    @ExcelProperty(value="工作状态(正常、手动、手调、加班、调休)",index=4)
    private String workStatus;

    // 真实原始日期---用来关联替换默认排班
    private String realDate;

}

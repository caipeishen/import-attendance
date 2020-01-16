package cn.bd.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.metadata.BaseRowModel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

/**
 * 手动排班
 * User: _Cps
 * Date: 2019.11.04 14:23
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AttendanceByHandShift extends BaseRowModel {

    @ExcelProperty(value="员工编号",index=0)
    private String userSerial;

    @ExcelProperty(value="员工姓名",index=1)
    private String userName;

    @ExcelProperty(value="结束日期",index=2)
    private Date toDate;

    @ExcelProperty(value="开始日期",index=3)
    private Date fromDate;


    @ExcelProperty(value="开始时间",index=4)
    private Date fromTime;

    @ExcelProperty(value="结束时间",index=5)
    private Date toTime;

    @ExcelProperty(value="排班班次",index=6)
    private String dws;



    private Date beginDate;

    private Date endDate;

}

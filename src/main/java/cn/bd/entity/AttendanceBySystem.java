package cn.bd.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.metadata.BaseRowModel;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.format.annotation.NumberFormat;

import java.util.Date;

/**
 * 系统排班
 * User: _Cps
 * Date: 2019.11.04 14:23
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AttendanceBySystem extends BaseRowModel {

    @ExcelProperty(value="员工编号",index=0)
    private String userSerial;

    @ExcelProperty(value="员工姓名",index=1)
    private String userName;

    @ExcelProperty(value="排班日期",index=2)
    private Date date;

    @ExcelProperty(value="排班班次",index=3)
    private String dws;



    private Date beginDate;

    private Date endDate;

}

package cn.bd.dao;

import cn.bd.entity.ImportAttendance;
import cn.bd.entity.ImportAttendance2;
import com.alibaba.fastjson.JSONObject;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * @author _Cps
 * @create 2019-02-14 10:25
 */
public interface ImportAttendanceMapper {

    Integer importAttendanceData(List<ImportAttendance2> list);

    List<ImportAttendance> getImportAttendanceList(ImportAttendance importAttendance);

    Integer execAttendanceProc();
}

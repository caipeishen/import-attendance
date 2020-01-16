package cn.bd.service;

import cn.bd.entity.ImportAttendance;
import cn.bd.entity.ImportAttendance2;

import java.text.ParseException;
import java.util.List;

/**
 * @author _Cps
 * @create 2019-02-14 10:25
 */
public interface ImportAttendanceService {

    Integer importAttendanceData(List<ImportAttendance2> list) throws ParseException;

    List<ImportAttendance> getImportAttendanceList(ImportAttendance importAttendance);

    Integer execAttendanceProc();
}

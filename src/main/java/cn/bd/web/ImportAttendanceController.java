package cn.bd.web;

import cn.bd.core.Result;
import cn.bd.core.ResultGenerator;
import cn.bd.entity.*;
import cn.bd.core.ResultPages;
import cn.bd.service.ImportAttendanceService;
import cn.bd.util.DateUtils;
import cn.bd.util.FileUtil;
import cn.bd.util.excel.ExcelUtil;
import com.alibaba.fastjson.JSONObject;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.apache.poi.ss.formula.functions.T;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.net.URLDecoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * @author _Cps
 * @create 2019-02-14 10:24
 */
@RestController
@RequestMapping("/importAttendance")
public class ImportAttendanceController {

    @Value("${web.upload-path}")
    private String upLoadPath;

    @Resource
    private ImportAttendanceService importAttendanceService;

    /**
     * 考勤班次时间
     */
    private static HashMap<String,String> dwsMap;

    static {
        dwsMap = new HashMap<String, String>();
        dwsMap.put("F301","08:00-16:00");
        dwsMap.put("M301","16:00-24:00");
        dwsMap.put("S301","24:00-08:00");
        dwsMap.put("F103","08:00-16:30");
        dwsMap.put("M201","16:30-01:00");
        dwsMap.put("F101","08:30-17:00");
        dwsMap.put("M220","20:00-04:00");
        dwsMap.put("F220","12:00-20:00");
        dwsMap.put("F211","07:00-15:30");
        dwsMap.put("F102","08:30-17:00");
        dwsMap.put("F351","06:00-14:00");
        dwsMap.put("M212","15:30-24:00");
        dwsMap.put("79","08:30-17:00");
    }


    SimpleDateFormat sdfDateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm");


    /**
     * 查询导入数据
     */
    @RequestMapping("/getImportData")
    public Result getImportData(@RequestBody ImportAttendance importAttendance){
        System.out.println(importAttendance.toString());
        PageHelper.startPage(importAttendance.getCurrent(),importAttendance.getPageSize());
        List<ImportAttendance> list = importAttendanceService.getImportAttendanceList(importAttendance);
        PageInfo<ImportAttendance> importAttendancePageInfo = new PageInfo<ImportAttendance>(list);
        return ResultGenerator.genSuccessResult(new ResultPages<ImportAttendance>(importAttendancePageInfo));
    }

    /**
     * 上传基础数据Excel文件
     * @return
     */
    @RequestMapping("/upLoadExcel")
    public Result upLoadExcel(HttpServletRequest request){
        String dirPath = request.getSession().getServletContext().getRealPath(upLoadPath);
        Result result = FileUtil.upLoadFile(dirPath,request);
        if(result.getCode()==200){
            //加载该Excel文件，并处理数据
            InputStream inputStream = null;
            File file = new File(result.getMessage());
            try {
                inputStream = new FileInputStream(file);
                processData(inputStream);
            } catch (FileNotFoundException e) {
                result = ResultGenerator.genFailResult("上传的文件未找到!");
            } catch (Exception e) {
                result = ResultGenerator.genFailResult(e.getMessage());
            }finally {
                if (inputStream != null) {
                    try {
                        inputStream.close();
                    } catch (IOException e) {
                        result = ResultGenerator.genFailResult("关闭文件流出现异常!");
                    }
                }
            }
        }else{
            result = ResultGenerator.genFailResult("上传考勤失败!");
        }
        return result;
    }


    /**
     * 导入基础数据Excel文件
     * @return
     */
    @RequestMapping("/importData")
    public Result importData(@RequestParam("file") MultipartFile file){
        Result result = null;
        try {
            result = processData(file.getInputStream());
        } catch (Exception e) {
            result = ResultGenerator.genFailResult(e.getMessage());
        }
        return result;
    }

    /**
     * Excel导入
     */
    public Result processData(InputStream inputStream) throws Exception{

        //系统
        List<AttendanceBySystem> attendanceBySystems = new ArrayList<AttendanceBySystem>();
        //手动
        List<AttendanceByHand> attendanceByHands = new ArrayList<AttendanceByHand>();
        //手调
        List<AttendanceByHandShift> attendanceByHandShifts = new ArrayList<AttendanceByHandShift>();
        //加班
        List<AttendanceByOverTime> attendanceByOverTimes = new ArrayList<AttendanceByOverTime>();
        //请假
        List<AttendanceByLeave> attendanceByLeaves = new ArrayList<AttendanceByLeave>();

        //接受数据
        List<Object> receiveList = ExcelUtil.ImportExcelPlus(inputStream);
        //理想数据
        List<ImportAttendance2> list = new ArrayList<ImportAttendance2>();

        for(Object o : receiveList){
            if(o instanceof AttendanceBySystem){
                //System.out.println("系统:"+o.toString());
                attendanceBySystems.add((AttendanceBySystem)o);
            }else if(o instanceof  AttendanceByHand){
                //System.out.println("手动:"+o.toString());
                attendanceByHands.add((AttendanceByHand)o);
            }else if(o instanceof  AttendanceByHandShift){
                //System.out.println("手调:"+o.toString());
                attendanceByHandShifts.add((AttendanceByHandShift)o);
            }else if(o instanceof  AttendanceByOverTime){
                //System.out.println("加班:"+o.toString());
                attendanceByOverTimes.add((AttendanceByOverTime)o);
            }else if(o instanceof  AttendanceByLeave){
                //System.out.println("调休:"+o.toString());
                attendanceByLeaves.add((AttendanceByLeave)o);
            }else{
                //System.err.println("未知:");
                throw new Exception("Excel中出现未知类型的数据!");
            }
        }

         //系统排班
        for(int i = 0;i < attendanceBySystems.size();i++){
            AttendanceBySystem a = attendanceBySystems.get(i);
            // 当用户编号不为空
            if(a.getUserSerial()!=null){
                String dws = dwsMap.get(a.getDws());
                //该班次为空，抛异常
                if(a.getDws()==null){
                    throw new Exception("系统排班Sheet中，第"+(i+1+1)+"行，不存在该班次");
                }
                if(a.getDws()!=null && dws==null){
                    if("OFF".equals(a.getDws()) || "****".equals(a.getDws())){
                        continue;
                    }else{
                        throw new Exception("系统排班Sheet中，第"+(i+1+1)+"行，不存在该班次");
                    }
                }
                String date = null;

                try {
                    date = sdfDate.format(a.getDate());
                }catch (Exception e){
                    throw new Exception("系统排班Sheet中，第"+(i+1+1)+"行，日期有误");
                }

                String[] time = time = dws.split("-");

                //设置开始时间
                a.setBeginDate(sdfDateTime.parse(date+" "+time[0]));

                //如果时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                long begin = sdfTime.parse(time[0]).getTime();
                long end = sdfTime.parse(time[1]).getTime();
                if(begin < end){
                    a.setEndDate(sdfDateTime.parse(date+" "+time[1]));
                }else{
                    //时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                    a.setEndDate(new Date(sdfDateTime.parse(date+" "+time[1]).getTime() + (24 * 60 * 60 * 1000)));
                }

                //如果结束时间小于开始时间，抛异常
                if(a.getBeginDate().getTime() > a.getEndDate().getTime()){
                    throw new Exception("系统排班Sheet中，第"+(i+1+1)+"行，开始时间大于结束时间!");
                }
                list.add(new ImportAttendance2(a.getUserSerial(),a.getUserName(),a.getBeginDate(),a.getEndDate(),"正常",sdfDate.format(a.getDate())));
            }
        }

        //手动排班
        for(int i = 0;i < attendanceByHands.size();i++){
            AttendanceByHand a = attendanceByHands.get(i);
            // 当用户编号不为空
            if(a.getUserSerial()!=null){
                String dws = dwsMap.get(a.getDws());
                //该班次为空，不执行以下操作
                if(a.getDws()==null || "".equals(a.getDws())){
                    continue;
                }
                if(a.getDws()!=null && dws==null){
                    if("OFF".equals(a.getDws()) || "****".equals(a.getDws())){
                        continue;
                    }else{
                        throw new Exception("手动排班Sheet中，第"+(i+1+1)+"行，不存在该班次");
                    }
                }
                // 并且状态不为空或者OFF的数据
                String date = null;

                try {
                    date = sdfDate.format(a.getDate());
                }catch (Exception e){
                    throw new Exception("手动排班Sheet中，第"+(i+1+1)+"行，日期有误");
                }

                String[] time = dws.split("-");

                //设置开始时间
                a.setBeginDate(sdfDateTime.parse(date+" "+time[0]));

                //如果时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                long begin = sdfTime.parse(time[0]).getTime();
                long end = sdfTime.parse(time[1]).getTime();
                if(begin < end){
                    a.setEndDate(sdfDateTime.parse(date+" "+time[1]));
                }else{
                    //时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                    a.setEndDate(new Date(sdfDateTime.parse(date+" "+time[1]).getTime() + (24 * 60 * 60 * 1000)));
                }

                //如果结束时间大于开始时间，抛异常
                if(a.getBeginDate().getTime() > a.getEndDate().getTime()){
                    throw new Exception("手动排班Sheet中，第"+(i+1+1)+"行，开始时间大于结束时间!");
                }
                list.add(new ImportAttendance2(a.getUserSerial(),a.getUserName(),a.getBeginDate(),a.getEndDate(),"手动",sdfDate.format(a.getDate())));
            }
        }


        //手调排班
        for(int i = 0;i < attendanceByHandShifts.size();i++){
            AttendanceByHandShift a = attendanceByHandShifts.get(i);
            // 当用户编号不为空
            if(a.getUserSerial()!=null){
                //真正有效数据（都是含有日期）
                if(a.getFromDate()!=null && a.getToDate()!=null){

                    String fromDate = null;
                    String toDate = null;

                    try {
                        fromDate = sdfDate.format(a.getFromDate());
                    }catch (Exception e){
                        throw new Exception("手调排班Sheet中，第"+(i+1+1)+"行，开始日期格式不正确!");
                    }

                    try {
                        toDate = sdfDate.format(a.getToDate());
                    }catch (Exception e){
                        throw new Exception("手调排班Sheet中，第"+(i+1+1)+"行，结束日期格式不正确!");
                    }

                    // 班次不为空，以班次为准
                    if(a.getDws()!=null){
                        String dws = dwsMap.get(a.getDws());
                        // 有班次的，需要将数据先查询并赋值班次信息
                        if(a.getDws()!=null && dws==null){
                            if("OFF".equals(a.getDws()) || "****".equals(a.getDws())){
                                continue;
                            }else{
                                throw new Exception("手调排班Sheet中，第"+(i+1+1)+"行，不存在该班次");
                            }
                        }
                        String date = null;

                        String[] time = dws.split("-");

                        try {
                            // 统一开始时间和结束时间的日期
                            unifiedDateFromAndTo(a);
                        }catch (Exception e){
                            throw new Exception("手调明细Sheet中，第"+(i+1+1)+"行，开始时间或结束时间格式不正确!");
                        }

                        //设置开始时间
                        a.setBeginDate(sdfDateTime.parse(fromDate+" "+time[0]));

                        //如果时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                        long beginLong = sdfTime.parse(time[0]).getTime();
                        long endLong = sdfTime.parse(time[1]).getTime();
                        if(beginLong < endLong){
                            a.setEndDate(sdfDateTime.parse(toDate+" "+time[1]));
                        }else{
                            //时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                            a.setEndDate(new Date(sdfDateTime.parse(toDate+" "+time[1]).getTime() + (24 * 60 * 60 * 1000)));
                        }
                    // 班次为空，以时间为准
                    }else{
                        String fromTime = null;
                        String toTime = null;

                        try {
                            fromTime = sdfTime.format(a.getFromTime());
                            //如果开始时间是00:00 开始日期和结束日期都要加一
                            if("00:00".equals(fromTime)){
                                fromDate = sdfDate.format(new Date(a.getFromDate().getTime()+(24*60*60*1000)));
                                toDate = sdfDate.format(new Date(a.getToDate().getTime()+(24*60*60*1000)));
                            }
                        }catch (Exception e){
                            throw new Exception("手调排班Sheet中，第"+(i+1+1)+"行，开始时间格式不正确!");
                        }

                        try {
                            toTime = sdfTime.format(a.getToTime());
                        }catch (Exception e){
                            throw new Exception("手调排班Sheet中，第"+(i+1+1)+"行，结束时间格式不正确!");
                        }

                        //设置开始时间
                        a.setBeginDate(sdfDateTime.parse(fromDate+" "+fromTime));

                        //如果时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                        long fromLong = a.getFromTime().getTime();
                        long endLong = a.getToTime().getTime();
                        if(fromLong < endLong){
                            a.setEndDate(sdfDateTime.parse(toDate+" "+toTime));
                        }else{
                            //时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                            a.setEndDate(new Date(sdfDateTime.parse(toDate+" "+toTime).getTime() + (24 * 60 * 60 * 1000)));
                        }
                    }
                    //如果结束时间大于开始时间，抛异常
                    if(a.getBeginDate().getTime() > a.getEndDate().getTime()){
                        throw new Exception("手调排班Sheet中，第"+(i+1+1)+"行，开始时间大于结束时间!");
                    }
                    list.add(new ImportAttendance2(a.getUserSerial(),a.getUserName(),a.getBeginDate(),a.getEndDate(),"手调",sdfDate.format(a.getFromDate())));
                }
            }
        }

        //加班排班
        for(int i = 0;i < attendanceByOverTimes.size();i++){
            AttendanceByOverTime a = attendanceByOverTimes.get(i);
            // 当用户编号不为空
            if(a.getUserSerial()!=null){
                String fromDate = null;
                String toDate = null;
                String fromTime = null;
                String toTime = null;

                try {
                    fromDate = sdfDate.format(a.getFromDate());
                }catch (Exception e){
                    throw new Exception("加班明细Sheet中，第"+(i+1+1)+"行，开始日期有误");
                }

                try {
                    toDate = sdfDate.format(a.getToDate());
                }catch (Exception e){
                    throw new Exception("加班明细Sheet中，第"+(i+1+1)+"行，结束日期有误");
                }


                try {
                    // 统一开始时间和结束时间的日期
                    unifiedDateFromAndTo(a);
                }catch (Exception e){
                    throw new Exception("加班明细Sheet中，第"+(i+1+1)+"行，开始时间或结束时间不正确!");
                }

                try {
                    fromTime = sdfTime.format(a.getFromTime());
                    //如果开始时间是00:00 开始日期和结束日期都要加一
                    if("00:00".equals(fromTime)){
                        fromDate = sdfDate.format(new Date(a.getFromDate().getTime()+(24*60*60*1000)));
                        toDate = sdfDate.format(new Date(a.getToDate().getTime()+(24*60*60*1000)));
                    }
                }catch (Exception e){
                    throw new Exception("加班明细Sheet中，第"+(i+1+1)+"行，开始时间有误");
                }

                try {
                    toTime = sdfTime.format(a.getToTime());
                }catch (Exception e){
                    throw new Exception("加班明细Sheet中，第"+(i+1+1)+"行，结束时间有误");
                }

                long begin = a.getFromTime().getTime();
                long end = a.getToTime().getTime();

                //设置开始时间
                a.setBeginDate(sdfDateTime.parse(fromDate+ " "+fromTime));

                //如果时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                if(begin < end){
                    a.setEndDate(sdfDateTime.parse(toDate+ " "+ toTime));
                }else{
                    //时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                    a.setEndDate(new Date(sdfDateTime.parse(toDate+ " "+toTime).getTime()+(24*60*60*1000)));
                }

                //如果开始时间大于结束时间，抛异常
                if(a.getBeginDate().getTime() > a.getEndDate().getTime()){
                    throw new Exception("加班明细Sheet中，第"+(i+1+1)+"行，开始时间大于结束时间!");
                }
                list.add(new ImportAttendance2(a.getUserSerial(),a.getUserName(),a.getBeginDate(),a.getEndDate(),"加班",sdfDate.format(a.getFromDate())));

            }
        }

        //调休排班
        for(int i = 0;i < attendanceByLeaves.size();i++){
            AttendanceByLeave a = attendanceByLeaves.get(i);
            // 当用户编号不为空
            if(a.getUserSerial()!=null){

                // 只有调休内容是 公司调休或者加班调休猜进行处理
                if("Company Adjustment Leave".equalsIgnoreCase(a.getLeaveType()) || "Overtime Adjustment Leave".equalsIgnoreCase(a.getLeaveType())){

                    String fromDate = null;
                    String toDate = null;
                    String fromTime = null;
                    String toTime = null;

                    try {
                        fromDate = sdfDate.format(a.getFromDate());
                    }catch (Exception e){
                        throw new Exception("调休明细Sheet中，第"+(i+1+1)+"行，开始日期有误");
                    }

                    try {
                        toDate = sdfDate.format(a.getToDate());
                    }catch (Exception e){
                        throw new Exception("调休明细Sheet中，第"+(i+1+1)+"行，结束日期有误");
                    }

                    try {
                        // 统一开始时间和结束时间的日期
                        unifiedDateFromAndTo(a);
                    }catch (Exception e){
                        throw new Exception("调休明细Sheet中，第"+(i+1+1)+"行，开始时间或结束时间不正确!");
                    }

                    try {
                        fromTime = sdfTime.format(a.getFromTime());
                        //如果开始时间是00:00 这里不需要 开始日期和结束日期都要加一
//                        if("00:00".equals(fromTime)){
//                            fromDate = sdfDate.format(new Date(a.getFromDate().getTime()+(24*60*60*1000)));
//                            toDate = sdfDate.format(new Date(a.getToDate().getTime()+(24*60*60*1000)));
//                        }
                    }catch (Exception e){
                        throw new Exception("调休明细Sheet中，第"+(i+1+1)+"行，开始时间有误");
                    }

                    try {
                        toTime = sdfTime.format(a.getToTime());
                    }catch (Exception e){
                        throw new Exception("调休明细Sheet中，第"+(i+1+1)+"行，结束时间有误");
                    }

                    long begin = a.getFromTime().getTime();
                    long end = a.getToTime().getTime();

                    //设置开始时间
                    a.setBeginDate(sdfDateTime.parse(fromDate+ " "+fromTime));

                    //如果时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                    if(begin < end){
                        a.setEndDate(sdfDateTime.parse(toDate+ " "+ toTime));
                    }else{
                        //时间跨天的话(结束时间大于开始时间)，结束日期需要+1
                        a.setEndDate(new Date(sdfDateTime.parse(toDate+ " "+toTime).getTime()+(24*60*60*1000)));
                    }

                    //如果开始时间大于结束时间，抛异常
                    if(a.getBeginDate().getTime() > a.getEndDate().getTime()){
                        throw new Exception("调休明细Sheet中，第"+(i+1+1)+"行，开始时间大于结束时间!");
                    }
                    list.add(new ImportAttendance2(a.getUserSerial(),a.getUserName(),a.getBeginDate(),a.getEndDate(),"调休",sdfDate.format(a.getFromDate())));

                }
            }

        }
        System.out.println(list.toString());
        //保存数据，并执行存储过程
        Integer num = importAttendanceService.importAttendanceData(list);
        //importAttendanceService.execAttendanceProc();
        return ResultGenerator.genSuccessResult("导入数据成功，正在执行岔分数据存储过程!");
    }

    /**
     * 统一 开始时间和结束时间 的日期
     * 时间(00:00:00) 的数据 有的会携带上日期(1900/1/1  0:00:00)，但是结束时间并不携带日期，导致数据会不是同一天的数据
     * @param obj
     * @throws ParseException
     */
    public void unifiedDateFromAndTo(Object obj) throws ParseException {
       if(obj instanceof AttendanceByHandShift){
            AttendanceByHandShift a = (AttendanceByHandShift)obj;
            a.setFromTime(sdfDateTime.parse("2019-01-01"+" "+sdfTime.format(a.getFromTime())+":00"));
            a.setToTime(sdfDateTime.parse("2019-01-01"+" "+sdfTime.format(a.getToTime())+":00"));
        }else if(obj instanceof AttendanceByOverTime){
           AttendanceByOverTime a = (AttendanceByOverTime)obj;
           a.setFromTime(sdfDateTime.parse("2019-01-01"+" "+sdfTime.format(a.getFromTime())+":00"));
           a.setToTime(sdfDateTime.parse("2019-01-01"+" "+sdfTime.format(a.getToTime())+":00"));
        }else if(obj instanceof AttendanceByLeave){
           AttendanceByLeave a = (AttendanceByLeave)obj;
           a.setFromTime(sdfDateTime.parse("2019-01-01"+" "+sdfTime.format(a.getFromTime())+":00"));
           a.setToTime(sdfDateTime.parse("2019-01-01"+" "+sdfTime.format(a.getToTime())+":00"));
        }
    }

    /**
     * Excel导出
     * @param response
     */
    @RequestMapping("/exportExcel")
    public void exportExcel(String isExec,String searchName,String startDate,String finishDate, HttpServletResponse response) throws IOException, InstantiationException, IllegalAccessException, ParseException {
        ImportAttendance importAttendance = new ImportAttendance();
        importAttendance.setIsExec(isExec);
        importAttendance.setSearchName(searchName);
        importAttendance.setStartDate(startDate);
        importAttendance.setFinishDate(finishDate);
        List<ImportAttendance> userList = importAttendanceService.getImportAttendanceList(importAttendance);
        ExcelUtil.ExportExcel("考勤数据_"+UUID.randomUUID().toString(), response, userList, ImportAttendance.class);
    }

    /**
     * 下载模板
     * @param response
     * @param request
     * @throws IOException
     */
    @RequestMapping(value = "/downLoadTemplate")
    public void downLoad(HttpServletResponse response, HttpServletRequest request) throws IOException {
        String fileName = "template"+".xlsx";
        ServletOutputStream out;
        FileUtil.setResponseHeader(fileName,response);
        String filePath = getClass().getResource("/downLoadTemplate/" + fileName).getPath();
        //System.out.println(filePath);
        filePath = URLDecoder.decode(filePath, "UTF-8");
        FileInputStream inputstream = new FileInputStream(filePath);
        out = response.getOutputStream();
        int b = 0;
        byte[] buffer = new byte[1024];
        while ((b = inputstream.read(buffer)) != -1) {
            // 4.写到输出流(out)中
            out.write(buffer, 0, b);
        }
        inputstream.close();

        if (out != null) {
            out.flush();
            out.close();
        }
    }


    /**
     * 格式化Excel时间
     * @param day
     * @return yyyy-MM-dd
     */
    private String formatExcelDate(int day) {
        Calendar calendar = new GregorianCalendar(1900,0,-1);
        Date gregorianDate = calendar.getTime();
        gregorianDate = calendar.getTime();
        String formatExcelDate = DateUtils.format(DateUtils.addDay(gregorianDate, day), DateUtils.YYYYMMDD);
        return formatExcelDate;
    }


}

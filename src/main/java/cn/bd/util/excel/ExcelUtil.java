package cn.bd.util.excel;

import cn.bd.entity.*;
import cn.bd.util.FileUtil;
import com.alibaba.excel.EasyExcelFactory;
import com.alibaba.excel.ExcelReader;
import com.alibaba.excel.ExcelWriter;
import com.alibaba.excel.metadata.BaseRowModel;
import com.alibaba.excel.metadata.Sheet;
import com.alibaba.excel.support.ExcelTypeEnum;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class ExcelUtil {

    /**
     *  升级版 导入Excel(xlsx版本)
     * @param inputStream
     * @param <T>
     * @return
     */
    public static  <T> List<T> ImportExcelPlus(InputStream inputStream){

        //Excel监听
        ExcelListener excelListener = new ExcelListener();

        //系统排班
        ExcelReader excelReaderBySystem = EasyExcelFactory.getReader(inputStream,excelListener);
        excelReaderBySystem.read(new Sheet(1, 1, AttendanceBySystem.class));
        excelReaderBySystem.read(new Sheet(2, 1, AttendanceByHand.class));
        excelReaderBySystem.read(new Sheet(3, 1, AttendanceByHandShift.class));
        excelReaderBySystem.read(new Sheet(4, 1, AttendanceByOverTime.class));
        excelReaderBySystem.read(new Sheet(5, 1, AttendanceByLeave.class));

        //封装成泛型返回值
        List<Object> listBySystem = excelListener.getDatas();
        List<T> listReturn = new ArrayList<T>();
        for (int i = 0; i < listBySystem.size(); i++) {
            T classObj = (T) listBySystem.get(i);
            listReturn.add(classObj);
        }
        return listReturn;
    }


    /**
     *  导入Excel(xlsx版本)
     * @param inputStream
     * @param tClass
     * @param <T>
     * @return
     */
    public static  <T> List<T> ImportExcel(InputStream inputStream,Integer sheetNumber,  Class<? extends BaseRowModel>  tClass){
        ExcelListener listener = new ExcelListener();
        ExcelReader excelReader = EasyExcelFactory.getReader(inputStream,listener);
        excelReader.read(new Sheet(sheetNumber, 1, tClass));
        List<Object> list = listener.getDatas();
        List<T> listReturn = new ArrayList<T>();
        for (int i = 0; i < list.size(); i++) {
            if(list.get(i)!=null){
                T classObj = (T) list.get(i);
                listReturn.add(classObj);
            }
        }
        return listReturn;
    }

    /**
     *  导出Excel(xlsx版本)
     * @param fileName
     * @param response
     * @param data
     * @param clazz
     * @throws IOException
     */
    public static void ExportExcel(String fileName, HttpServletResponse response, List<? extends BaseRowModel> data, Class<? extends BaseRowModel> clazz) throws IOException {
        ServletOutputStream out = response.getOutputStream();
        FileUtil.setResponseHeader(fileName+".xlsx",response);
        ExcelWriter writer = new ExcelWriter(out, ExcelTypeEnum.XLSX, true);
        Sheet sheet1 = new Sheet(1, 0, clazz);

//        sheet1.setSheetName("第一个sheet");
        writer.write(data, sheet1);
        writer.finish();

        out.flush();
    }



}

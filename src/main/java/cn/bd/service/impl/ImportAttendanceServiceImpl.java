package cn.bd.service.impl;

import cn.bd.core.ResultGenerator;
import cn.bd.dao.ImportAttendanceMapper;
import cn.bd.entity.ImportAttendance;
import cn.bd.entity.ImportAttendance2;
import cn.bd.service.ImportAttendanceService;
import cn.bd.util.DateUtils;
import com.alibaba.fastjson.JSONArray;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * @author _Cps
 * @create 2019-02-14 10:25
 */
@Service
public class ImportAttendanceServiceImpl implements ImportAttendanceService {

    @Resource
    private ImportAttendanceMapper importAttendanceMapper;

    SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sdfDateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    /*
     * 1.处理00:00:00整点数据
     * 2.处理跨天的数据
     * 表明该类（class）或方法（method）受事务控制
     * @param propagation  设置传播行为
     * @param isolation 设置隔离级别
     * @param rollbackFor 设置需要回滚的异常类，默认为RuntimeException
     */
    @Override
    @Transactional(propagation = Propagation.REQUIRED, isolation = Isolation.READ_COMMITTED, rollbackFor = Exception.class)
    public Integer importAttendanceData(List<ImportAttendance2> list) throws ParseException {
        List<ImportAttendance2> addList = new ArrayList<ImportAttendance2>();
        List<ImportAttendance2> removeList = new ArrayList<ImportAttendance2>();
        //开始的时间以00:00:00的， 日期要加一 但是接受的数据是 2019-01-01 24:00:00 自动转换为了 2019-01-02 00:00 也就不用日期加一
        //modifyByBeginDate(list);
        for(int i=0;i<list.size();i++){
            //修改结束时间（如果是00:00:00整点，那么时间改成前一天的23:59:59）
            modifyEndDate(list.get(i));
            //得出相差的天数
            Integer daySub = getHourSub(list.get(i).getBeginDate(),list.get(i).getEndDate()) / 24;
            // 跨日期处理， 大于一天的数据需要进行处理
            if(daySub > 0){
                // 循环遍历跨天数据
                daySub += 1;
                for(int j = 0;j < daySub;j++){

                    // 开始时间
                    Calendar beginDate = Calendar.getInstance();
                    beginDate.setTime(list.get(i).getBeginDate());
                    beginDate.add(Calendar.DATE,j);
                    // 结束时间
                    Calendar endDate = Calendar.getInstance();
                    endDate.setTime(list.get(i).getEndDate());
                    endDate.add(Calendar.DATE,-(daySub-j-1));

                    int beginHour = beginDate.get(Calendar.HOUR_OF_DAY);
                    int endHour = endDate.get(Calendar.HOUR_OF_DAY);

                    // 跨时间，开始的日期不等于结束的日期，需要拆分时间（2019-01-01 16:00 - 2019-01-01 23:59）（2019-01-02 00:00 - 2019-01-02 01:00）
                    if(beginHour > endHour){

                        String begin = sdfDate.format(beginDate.getTime());
                        String end = sdfDate.format(endDate.getTime());

                        // 第二天00:00时间
                        Date current = new Date(sdfDate.parse(begin).getTime() + (24*60*60*1000));

                        // 第一天的结束时间 23:59:59
                        Date beforeEnd = new Date(current.getTime() - 1000);

                        // 循环的时候 真实日期也要自增
                        Date realDate = new Date(sdfDate.parse(list.get(i).getRealDate()).getTime()+(24*60*60*1000)*j);

                        ImportAttendance2 before = new ImportAttendance2(list.get(i).getUserNo(),list.get(i).getUserName(),beginDate.getTime(),beforeEnd,list.get(i).getWorkStatus(),sdfDate.format(realDate));
                        ImportAttendance2 after = new ImportAttendance2(list.get(i).getUserNo(),list.get(i).getUserName(),current,endDate.getTime(),list.get(i).getWorkStatus(),sdfDate.format(realDate));

                        addList.add(before);
                        addList.add(after);

                    }else{
                        // 循环的时候 真实日期也要自增
                        Date realDate = new Date(sdfDate.parse(list.get(i).getRealDate()).getTime()+(24*60*60*1000)*j);
                        ImportAttendance2 ia = new ImportAttendance2(list.get(i).getUserNo(),list.get(i).getUserName(),beginDate.getTime(),endDate.getTime(),list.get(i).getWorkStatus(),sdfDate.format(realDate));
                        addList.add(ia);
                    }
                }
                removeList.add(list.get(i));
            }else{
                String begin = sdfDate.format(list.get(i).getBeginDate());
                String end = sdfDate.format(list.get(i).getEndDate());
                // 跨时间，开始的日期不等于结束的日期，需要拆分时间（2019-01-01 16:00 - 2019-01-01 23:59）（2019-01-02 00:00 - 2019-01-02 01:00）
                if(!begin.equals(end)){
                    // current标识第二天00:00时间
                    Date current = new Date( sdfDate.parse(begin).getTime() + (24 * 60 * 60 * 1000) );
                    ImportAttendance2 ia2 = new ImportAttendance2(list.get(i).getUserNo(),list.get(i).getUserName(),current,list.get(i).getEndDate(),list.get(i).getWorkStatus(),list.get(i).getRealDate());
                    //顺序不能反了
                    addList.add(ia2);
                    list.get(i).setEndDate(new Date(current.getTime()-1000));
                }
            }
        }
        // 不能放到上面循环中处理，因为遍历使用的索引，删除元素，集合长度会改变
        for(Integer i =0;i<removeList.size();i++){
            // 移除循环的元素 使用Integer的intValue方法，因为集合的remove方法有重载remove(Object)、remove(int)
            list.remove(removeList.get(i));
        }
        // 不能放到上面循环中处理，因为遍历使用的索引，添加元素，集合长度会改变
        for(Integer i =0;i<addList.size();i++){
            list.add(addList.get(i));
        }
        String listJSON = JSONArray.toJSONStringWithDateFormat(list,"yyyy-MM-dd HH:mm:ss");
        //System.err.println(listJSON);


        //多线程批量处理
        try {
            ExecutorService cachedThreadPool = Executors.newCachedThreadPool();
            Integer numThread = 200;//每个线程携带200条数据
            Integer count = list.size() % numThread == 0 ? list.size()/numThread : (list.size()/numThread + 1);
            //记录线程个数
            CountDownLatch latch = new CountDownLatch(count);
            for (int i = 0; i < count; i++) {
                int index = i;
                cachedThreadPool.execute(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            if(index == count-1){//最后一次
                                List<ImportAttendance2> subList = list.subList(index * numThread,list.size());
                                importAttendanceMapper.importAttendanceData(subList);
                            }else{//除了最后一次
                                List<ImportAttendance2> subList = list.subList(index * numThread,index * numThread + numThread);
                                importAttendanceMapper.importAttendanceData(subList);
                            }
                        }catch (Exception e){
                            e.printStackTrace();
                        }finally {
                            latch.countDown();
                        }
                    }
                });
            }
            //等待所有线程执行完
            latch.await();
            //异步执行同步存储过程
            cachedThreadPool.execute(new Runnable() {
                @Override
                public void run() {
                    importAttendanceMapper.execAttendanceProc();
                }
            });

        }catch (Exception e){
            throw new Exception("多线程出现问题!");
        }finally {
            return 1;
        }
        //return importAttendanceMapper.importAttendanceData(list);
    }

    @Override
    public List<ImportAttendance> getImportAttendanceList(ImportAttendance importAttendance) {
        return importAttendanceMapper.getImportAttendanceList(importAttendance);
    }

    @Override
    public Integer execAttendanceProc() {
        return importAttendanceMapper.execAttendanceProc();
    }


    /**
     * 如果开始时间以00:00:00开始，日期要加一
     * @param list
     */
//    public void modifyByBeginDate(List<ImportAttendance2> list){
//        //本来日期要加+1 ， 但是接受的数据是 2019-01-01 24:00:00 自动转换为了 2019-01-02 00:00 也就不用日期加一
//        for(ImportAttendance2 ia : list){
//            Calendar endCalendar = Calendar.getInstance();
//            endCalendar.setTime(ia.getBeginDate());
//            int hour =  endCalendar.get(Calendar.HOUR_OF_DAY);
//            if(hour==0){
//                //日期加一天
//                int oneDayTime = 24 * 60 * 60 * 1000;
//                System.err.println(ia.getBeginDate() + "\t" + new Date(ia.getBeginDate().getTime()+ oneDayTime));
//                ia.setBeginDate(new Date(ia.getBeginDate().getTime()+ oneDayTime));
//                ia.setEndDate(new Date(ia.getEndDate().getTime()+ oneDayTime));
//            }
//        }
//    }

    /**
     * 修改结束时间（2019-01-02 00:00:00 → 2019-01-01 23:59:59）
     * 这里对象是引用类型，所以修改对象，里面的数据也会修改
     */
    public void modifyEndDate(ImportAttendance2 ia){
        Calendar endCalendar = Calendar.getInstance();
        endCalendar.setTime(ia.getEndDate());
        int hour = endCalendar.get(Calendar.HOUR_OF_DAY);
        int minute = endCalendar.get(Calendar.MINUTE);
        if(hour == 0 && minute ==0){
            ia.setEndDate(new Date((ia.getEndDate().getTime()-1000)));
        }
    }

    /**
     * <li>功能描述：时间相减得到天数
     * @param beginDate
     * @param endDate
     * @return
     * long
     * @author Administrator
     */
    public Integer getHourSub(Date beginDate, Date endDate){
        Long hour = (endDate.getTime() - beginDate.getTime())/(60*60*1000);
        return hour.intValue();
    }


}

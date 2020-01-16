package cn.bd;

import cn.bd.entity.ImportAttendance;
import cn.bd.entity.ImportAttendance2;
import com.alibaba.excel.ExcelReader;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.web.bind.annotation.RequestMapping;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@RunWith(SpringRunner.class)
@SpringBootTest
public class ApplicationTest {
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
    }
    @Test
    public void test() throws ParseException, InterruptedException {

//        SimpleDateFormat sdfDateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//
//        Date date = sdfDateTime.parse("2019-01-01 00:00:00");
//
//        SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm");
//
//        Date a = sdfDateTime.parse("1900-01-01"+" "+"08:00:00");
//
//        System.out.println(a.toString());
        //System.out.println(from.getTime()+"\t"+to.getTime()+"\t"+(from.getTime()<to.getTime()));

        ExecutorService executorService = Executors.newCachedThreadPool();

        CountDownLatch latch = new CountDownLatch(100);

        for(int i = 0;i<100;i++){
            int index = i;
            executorService.execute(new Runnable() {
                @Override
                public void run() {
                    System.out.println(index);
                    latch.countDown();
                }
            });
        }

        latch.await();

        executorService.execute(new Runnable() {
            @Override
            public void run() {
                System.out.println("结束!");
            }
        });

    }

}


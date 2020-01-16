package cn.bd.core;

import com.github.pagehelper.PageInfo;
import lombok.Data;

import java.util.List;

@Data
public class ResultPages<T> {

    private Integer current;
    private Integer pageSize;

    private Integer pages;
    private Long total;

    private List<T> list;

    public ResultPages() {

    }

    public ResultPages(PageInfo<T> page){
        this.current = page.getPageNum();
        this.pageSize = page.getPageSize();
        this.total = page.getTotal();
        this.pages = page.getPages();
        this.list = page.getList();
    }


}

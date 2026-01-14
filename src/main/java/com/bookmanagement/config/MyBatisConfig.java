package com.bookmanagement.config;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;
import java.beans.PropertyVetoException;
import java.util.Properties;
import com.mchange.v2.c3p0.ComboPooledDataSource;

@Configuration
@ComponentScan(basePackages = {"com.bookmanagement.service", "com.bookmanagement.dao"})
@EnableTransactionManagement
@PropertySource("classpath:application.properties")
@MapperScan("com.bookmanagement.dao")
public class MyBatisConfig {

    @Autowired
    private Environment env;

    @Bean
    public DataSource dataSource() throws PropertyVetoException {
        // 添加调试信息

        String driver = env.getProperty("jdbc.driver");
        String url = env.getProperty("jdbc.url");
        String username = env.getProperty("jdbc.username");
        String password = env.getProperty("jdbc.password");

       if (username == null || username.trim().isEmpty()) {
            System.err.println("错误：用户名为空！");
            System.err.println("请检查application.properties文件是否存在且配置正确");
        }



        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        try {
            dataSource.setDriverClass(driver);
            dataSource.setJdbcUrl(url);
            dataSource.setUser(username);
            dataSource.setPassword(password);

            // 连接池配置
            dataSource.setInitialPoolSize(5);
            dataSource.setMinPoolSize(5);
            dataSource.setMaxPoolSize(20);
            dataSource.setMaxIdleTime(300);
            dataSource.setAcquireIncrement(5);

            // 测试连接
            dataSource.setTestConnectionOnCheckin(true);
            dataSource.setTestConnectionOnCheckout(false);
            dataSource.setPreferredTestQuery("SELECT 1");

        } catch (Exception e) {
            System.err.println("数据库连接池初始化失败: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }

        return dataSource;
    }

    @Bean
    public SqlSessionFactory sqlSessionFactory() throws Exception {
        SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        sessionFactory.setDataSource(dataSource());

        // 配置MyBatis
        org.apache.ibatis.session.Configuration configuration =
                new org.apache.ibatis.session.Configuration();
        configuration.setMapUnderscoreToCamelCase(true);
        configuration.setCacheEnabled(true);
        configuration.setLazyLoadingEnabled(true);
        configuration.setAggressiveLazyLoading(false);
        configuration.setDefaultStatementTimeout(25);
        configuration.setLogPrefix("[MyBatis] ");

        // 设置日志实现
        configuration.setLogImpl(org.apache.ibatis.logging.stdout.StdOutImpl.class);

        sessionFactory.setConfiguration(configuration);

        // 设置mapper文件位置
        Resource[] mapperResources = new PathMatchingResourcePatternResolver()
                .getResources("classpath:mapper/*.xml");
        sessionFactory.setMapperLocations(mapperResources);

        // 设置类型别名
        sessionFactory.setTypeAliasesPackage("com.bookmanagement.entity");

        return sessionFactory.getObject();
    }

    @Bean
    public SqlSessionTemplate sqlSessionTemplate(SqlSessionFactory sqlSessionFactory) {
        return new SqlSessionTemplate(sqlSessionFactory);
    }

    @Bean
    public PlatformTransactionManager transactionManager() throws PropertyVetoException {
        return new DataSourceTransactionManager(dataSource());
    }
}
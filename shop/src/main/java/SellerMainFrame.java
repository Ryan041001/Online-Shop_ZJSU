import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class SellerMainFrame extends JFrame {
    private String username;

    public SellerMainFrame(String username) {
        this.username = username;
        setTitle("商家主界面 - " + username);
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(7, 1));

        JButton addCategoryButton = new JButton("添加商品品类");
        //JButton viewCategoriesButton = new JButton("查看品类列表");
        JButton addProductButton = new JButton("添加商品");
        JButton viewProductsButton = new JButton("查看商品列表");
        JButton viewOrderButton = new JButton("查看订单列表");
        JButton processOrderButton = new JButton("处理订单");
        //JButton processReturnButton = new JButton("处理退货");
        JButton logoutButton = new JButton("退出登录");

        panel.add(addCategoryButton);
        //panel.add(viewCategoriesButton);
        panel.add(addProductButton);
        panel.add(viewProductsButton);
        panel.add(viewOrderButton);
        panel.add(processOrderButton);
        //panel.add(processReturnButton);
        panel.add(logoutButton);

        add(panel);

        // 添加商品品类
        addCategoryButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                new AddCategoryFrame().setVisible(true); // 打开添加商品品类界面
            }
        });

        // 查看品类列表
//        viewCategoriesButton.addActionListener(new ActionListener() {
//            @Override
//            public void actionPerformed(ActionEvent e) {
//                new ViewCategoriesFrame().setVisible(true); // 打开查看品类列表界面
//            }
//        });

        // 添加商品品类
//        addCategoryButton.addActionListener(new ActionListener() {
//            @Override
//            public void actionPerformed(ActionEvent e) {
//                new AddCategoryFrame().setVisible(true); // 打开添加商品品类界面
//            }
//        });

        // 添加商品
        addProductButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                new AddProductFrame(username).setVisible(true); // 打开添加商品界面
            }
        });

        // 查看商品列表
        viewProductsButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                new ViewProductsFrame(username, true).setVisible(true); // 打开查看商品列表界面
            }
        });
        // 查看订单列表
        viewOrderButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                new ViewOrdersFrame(username).setVisible(true); // 打开处理订单界面
            }
        });
        // 处理订单
        processOrderButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                new ProcessOrderFrame(username).setVisible(true); // 打开处理订单界面
            }
        });

        // 处理退货
//        processReturnButton.addActionListener(new ActionListener() {
//            @Override
//            public void actionPerformed(ActionEvent e) {
//                new ProcessReturnFrame(username).setVisible(true); // 打开处理退货界面
//            }
//        });

        // 退出登录
        logoutButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                dispose(); // 关闭当前窗口
                new LoginFrame().setVisible(true); // 返回登录界面
            }
        });
    }
}
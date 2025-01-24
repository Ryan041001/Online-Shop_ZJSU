import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class ViewProductsFrame extends JFrame {
    private String username;
    private JList<String> productList;
    private DefaultListModel<String> listModel;

    public ViewProductsFrame(String username, boolean isSeller) {
        this.username = username;
        setTitle("商品列表 - " + username);
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new BorderLayout());

        // 商品列表
        listModel = new DefaultListModel<>();
        productList = new JList<>(listModel);
        JScrollPane scrollPane = new JScrollPane(productList);
        panel.add(scrollPane, BorderLayout.CENTER);

        // 加入购物车按钮
        JButton addToCartButton = new JButton("加入购物车");
        panel.add(addToCartButton, BorderLayout.SOUTH);

        add(panel);

        // 加载商品列表
        loadProducts(isSeller);

        // 加入购物车事件
        addToCartButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                addToCart();
            }
        });
    }

    // 加载商品列表
    private void loadProducts(boolean isSeller) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt;

                cstmt = conn.prepareCall("{call GetProducts}"); // 不传递 @SellerID 参数

            ResultSet rs = cstmt.executeQuery();

            while (rs.next()) {
                String productInfo = "商品ID: " + rs.getInt("ProductID") + " - " +
                        rs.getString("ProductName") + " - 价格: " + rs.getDouble("Price");
                listModel.addElement(productInfo);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "加载商品列表失败: " + ex.getMessage());
        }
    }

    // 加入购物车
    private void addToCart() {
        String selectedProduct = productList.getSelectedValue();
        if (selectedProduct == null) {
            JOptionPane.showMessageDialog(this, "请选择一个商品！");
            return;
        }

        // 解析商品ID
        int productId = Integer.parseInt(selectedProduct.split(" - ")[0].replace("商品ID: ", ""));

        // 获取用户ID
        int userId = getUserId(username);
        if (userId == -1) {
            JOptionPane.showMessageDialog(this, "错误：未找到用户ID！");
            return;
        }

        // 默认数量为1
        int quantity = 1;

        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call AddToCart(?, ?, ?)}");
            cstmt.setInt(1, userId);          // @UserID (INT)
            cstmt.setInt(2, productId);       // @ProductID (INT)
            cstmt.setInt(3, quantity);        // @Quantity (INT)
            cstmt.execute();

            JOptionPane.showMessageDialog(this, "商品已加入购物车！");
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "加入购物车失败: " + ex.getMessage());
        }
    }

    // 根据用户名获取用户ID
    private int getUserId(String username) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            PreparedStatement pstmt = conn.prepareStatement("SELECT UserID FROM Users WHERE Username = ?");
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("UserID");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return -1; // 如果未找到用户，返回 -1
    }
}
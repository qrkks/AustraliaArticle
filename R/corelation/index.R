# 加载数据
# 请确保将数据文件的路径替换为实际的文件路径
data <- read.csv("db/purged/data.csv")  # 修改为实际的文件路径

# 定义目标变量 "经济健康总分" 和所有自变量
target <- data$经济健康总分
X <- data[, !colnames(data) %in% c("经济健康总分", "序号", "经济毒性分级")]  # 根据需要调整，排除无关变量

# 创建一个空的数据框用于存储特征、相关性系数和 p 值
univariate_corr_results <- data.frame(Feature = character(),
                                      Correlation_Coefficient = numeric(),
                                      P_Value = numeric(),
                                      stringsAsFactors = FALSE)

# 计算每个特征与目标变量的相关性系数和 p 值
for (feature in colnames(X)) {
  test_result <- cor.test(X[[feature]], target)  # 计算相关系数和 p 值
  corr_coeff <- test_result$estimate
  p_value <- test_result$p.value
  
  # 将结果添加到数据框中
  univariate_corr_results <- rbind(univariate_corr_results,
                                   data.frame(Feature = feature,
                                              Correlation_Coefficient = corr_coeff,
                                              P_Value = p_value))
}

# 按 p 值排序结果
univariate_corr_results_sorted <- univariate_corr_results[order(univariate_corr_results$P_Value), ]

# 显示结果
print(univariate_corr_results_sorted)

# 可选：将结果保存为 CSV 文件
write.csv(univariate_corr_results_sorted, "R/corelation/univariate_correlation_results.csv", row.names = FALSE)



library(glmnet)

# 标准化数据
X_scaled <- scale(as.matrix(X))
target <- as.vector(target)  # 转换为向量

# 使用 cv.glmnet 进行交叉验证选择最佳 lambda
lasso_cv <- cv.glmnet(X_scaled, target, alpha = 1, family = "gaussian")

# 提取最佳 lambda 下的系数并转换为矩阵
lasso_coef <- as.matrix(coef(lasso_cv, s = "lambda.min"))
selected_features <- rownames(lasso_coef)[lasso_coef != 0]

# 输出结果
cat("Selected features:", selected_features, "\n")
print(lasso_coef[lasso_coef != 0])

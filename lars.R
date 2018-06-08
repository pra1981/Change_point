my_lars <- function(x,y){
  m <- ncol(x)
  x <- scale(x)                 #��׼��
  y <- scale(y,scale = F)       #���Ļ�
  miu_hat <- 0                  #��ǰ����ֵ
  beta_hat <- matrix(0, nrow = m, ncol = m)      #ϵ������ֵ
  c <- t(x)%*%(y-miu_hat)       #���ϵ������
  c_max <- max(abs(c))          #���ϵ�����ֵ
  a_index <- which.max(abs(c))
  s <- sign(c[a_index])
  k <- 1
  x_current <- s*x[,a_index]
  while (k<m) {
    g_current <- t(x_current)%*%x_current
    A_current <- 1/drop(sqrt(rep(1,k)%*%solve(g_current)%*%rep(1,k)))
    w_current <- A_current*solve(g_current)%*%rep(1,k)
    u_current <- x_current%*%w_current
    a <- t(x)%*%u_current
    y_1 <- (c(c_max)-c)/(A_current-a)
    y_2 <- (c(c_max)+c)/(A_current+a)
    y_1[y_1<0] <- 1/0
    y_1[a_index] <- 1/0
    y_2[y_2<0] <- 1/0
    y_2[a_index] <- 1/0
    eta <- min(y_1,y_2)
    miu_hat <- miu_hat+eta*u_current
    beta_hat[a_index,k] <- (solve(t(x[,a_index])%*%x[,a_index])%*%t(x[,a_index])%*%miu_hat)
    j <- which(c(y_1,y_2)==eta)
    j <- ifelse(j>m,j-m,j)
    a_index <- c(a_index,j)
    c_max <- c_max-eta*A_current
    c <- t(x)%*%(y-miu_hat)
    s <- c(s,sign(c[j]))
    k <- k+1
    x_current <- cbind(x_current,s[k]*x[,j])
  }
  beta_hat[,k] <- solve(t(x)%*%x)%*%t(x)%*%y
  return(beta_hat)
}





#����
library(lars)
library(ggplot2)
library(reshape2)
data(diabetes)
attach(diabetes)
w <- cbind(diabetes$x, diabetes$y, diabetes$x2)
x <- as.matrix(w[, 1:10])
y <- as.matrix(w[, 11])#��Ӧ����
x2 <- as.matrix(w[, 12:21])
laa <- lars(x2, y,type = 'lasso') #lars����Ĭ�Ϸ���Ϊlasso
plot(laa)
cva <- cv.lars(x2, y, K = 10, plot.it = TRUE)
best <- cva$index[which.min(cva$cv)]
coef <- coef.lars(laa, mode = "fraction", s = best)
#lars��
coef
#lasso��
coef1 <- my_lars(x2,y)

#ϵ���켣ͼ
a <- as.data.frame(cbind(coef1,y= 1:ncol(x2)))
a1 <- melt(a,id.vars = 'y')
ggplot(a1,aes(variable,value,group=y))+geom_line(aes(col=y))
plot(laa)

##lasso����
b<- seq(0,1,length.out =200)
coef1 <- matrix(nrow =200 ,ncol = ncol(x2))
for (i in 1:200) {
  coef1[i,] <- lasso(x2,y,t=b[i]*sum(abs(solve(t(x2)%*%x2)%*%t(x2)%*%y)))
}
a <- as.data.frame(cbind(t(coef1),y= 1:ncol(x2)))
a1 <- melt(a,id.vars = 'y')
ggplot(a1,aes(variable,value,group=y))+geom_line(aes(col=y))
plot(laa)



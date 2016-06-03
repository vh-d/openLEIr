getIEProxy <- function() {
  syscall <-   system2(command = "REG",
                       args = "QUERY \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\" /v proxyServer",
                       stdout = T, stderr = T)

  syscall <- paste0(syscall, collapse = "")

  # match proxy url:port
  proxy <- regexpr("\\H*$", syscall, perl = T )
  proxy <- regmatches(syscall, proxy)

  proxy <- strsplit(proxy, split = ":", fixed = T)[[1]] # split url and port

  return(proxy)
}

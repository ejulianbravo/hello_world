library(httr2)
library(jsonlite)
library(usethis)

usethis::edit_r_environ() #loads API key from Renviron

# Set your API key once (or store it in .Renviron as OPENAI_API_KEY)
api_key <- Sys.getenv("OPENAI_API_KEY")
api_url <- "https://api.openai.com/v1/chat/completions"

call_llm <- function(prompt,
                     context = NULL,
                     model = "gpt-5.1",
                     temperature = 0.2) {
  
  if (api_key == "") stop("Set OPENAI_API_KEY in your environment.")
  
  # Construct messages list
  messages <- list()
  
  if (!is.null(context) && nzchar(context)) {
    messages <- append(messages, list(list(
      role = "system",
      content = context
    )))
  }
  
  messages <- append(messages, list(list(
    role = "user",
    content = prompt
  )))
  
  req <- request(api_url) |>
    req_auth_bearer_token(api_key) |>
    req_body_json(list(
      model = model,
      temperature = temperature,
      messages = messages
    ))
  
  resp <- req_perform(req)
  out  <- resp_body_json(resp)
  
  # Extract assistant message
  out$choices[[1]]$message$content
}

# Example use:
result <- call_llm(
  prompt = "Explain the role of dopamine in reward learning.",
  context = "You are a concise academic assistant."
)

cat(result)

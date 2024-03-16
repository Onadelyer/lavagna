variable "db_instance_class" {
  description = "Размер экземпляра базы данных"
}

variable "db_engine" {
  description = "Тип движка базы данных"
}

variable "db_engine_version" {
  description = "Версия движка базы данных"
}

variable "db_identifier" {
  description = "Идентификатор базы данных"
}

variable "db_username" {
  description = "Имя пользователя для базы данных"
}

variable "db_password" {
  description = "Пароль для базы данных"
}

variable "db_allocated_storage" {
  description = "Размер хранилища для базы данных"
}

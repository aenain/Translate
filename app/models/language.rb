class Language
  AVAILABLE = %w{pl de}
  PRIMARY = Settings.language.primary.symbol
  FOREIGN = AVAILABLE - [PRIMARY]
end
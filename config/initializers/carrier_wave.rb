if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Amazon S3用の設定
      :provider              => 'AWS',
      :region                => ENV['ap-northeast-1'],     # 例: 'ap-northeast-1'
      :aws_access_key_id     => ENV['AKIAJ5Z2HL4TV76OEQTA'],
      :aws_secret_access_key => ENV['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']
    }
    config.fog_directory     =  ENV['railstutorial11']
  end
end
class Task < ApplicationRecord
  has_one_attached :image
  validates :name, presence: true
  validates :name, length: { maximum: 30 }
  validate :validate_name_not_including_comma

  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }

  def self.csv_attributes
    ["name", "description", "created_at", "updated_at"]     #CSVデータにどの属性をどの順番で出力するかをcsv_attributesというクラスメソッドから得られるように定義している
  end

  def self.generate_csv
    CSV.generate(headers: true) do |csv|                    #CSV.generateを使ってCSVデータの文字列を生成。生成した文字列がgenerate_csvクラスメソッドの戻り値となる。
      csv << csv_attributes                                 #CSVの1行目としてヘッダを出力する。
      all.each do |task|
        csv << csv_attributes.map{ |attr| task.send(attr) } #allメソッドで全タスクを取得。1レコード毎にCSVの1行を出力する。
      end
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|          #CSV.foreachを使ってCSVファイルを1行ずつ読み込みます。headers: trueにより1行目をヘッダとして無視するようにしている。
      task = new                                            #Task.newと同意(selfがTaskの状態の為)
      task.attributes = row.to_hash.slice(*csv_attributes)  #CSVの1行のデータであるrowのto_hashメソッドを呼ぶ事で属性のデータをハッシュの形に変換している。
      task.save!                                            #Taskインスタンスをデータベースに登録
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  private

  def validate_name_not_including_comma
    errors.add(:name, 'にカンマを含めることはできません') if name&.include?('.')
  end
end

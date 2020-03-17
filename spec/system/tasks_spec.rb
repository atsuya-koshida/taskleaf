require 'rails_helper'

describe 'タスク管理機能', type: :system do
  describe '一覧表示機能' do
    let(:user_a) { FactoryBot.create(:user, name: 'ユーザーA', email: 'a@example.com') }
    let(:user_b) { FactoryBot.create(:user, name: 'ユーザーB', email: 'b@example.com') }

    before do
      FactoryBot.create(:task, name: '最初のタスク', user: user_a) # この時点でユーザーAが実際にDBに登録される。作成者がユーザーAであるタスクを作成しておく。
      visit login_path  # ユーザーAでログインする
      fill_in 'メールアドレス', with: login_user.email # メールアドレスを入力する
      fill_in 'パスワード', with: login_user.password         # パスワードを入力する
      click_button 'ログインする'                    # ログインするボタンを押す
    end

    context 'ユーザーAがログインしている時' do
      let(:login_user) { user_a }

      it 'ユーザーAが作成したタスクが表示される' do
        expect(page).to have_content '最初のタスク'  # 作成済みのタスクの名称が画面上に表示されている事を確認
      end
    end

    context 'ユーザーBがログインしている時' do
      let(:login_user) { user_b }
      it 'ユーザーAが作成したタスクが表示されない' do
        expect(page).to have_no_content '最初のタスク' # ユーザーAが作成したタスクの名称が画面上に表示されていない事を確認
      end
    end
  end
end
require 'spec_helper'

describe ArticlesController do
  let(:author) { FactoryGirl.create :account }
  let!(:authors_article) { FactoryGirl.create :article, author: author }
  let!(:other_article) { FactoryGirl.create :article }
  
  let(:valid_attributes) { {title: "Sex life of the Ping Pong ball" } }

  # TODO it should require user to be logged in to access ALL actions
  
  context "while not logged in" do
    describe "GET index" do
      subject { get :index }
      
      it { expect(subject).to redirect_to login_path }
      it { subject; expect(flash[:alert]).to be_present }
    end
  end
  
  context "while logged in as the blog author" do
    before { session[:account_id] = author.id }
    
    describe "GET index" do
      before { get :index }

      it { expect(assigns(:articles)).to eq [authors_article] }
      it { expect(response).to render_template 'index' }
    end
  
    describe "GET show" do
      before { get :show, id: authors_article.to_param }

      it { expect(assigns(:article)).to eq authors_article }
      it { expect(response).to render_template 'show' }
    end
  
    describe "GET new" do
      before { get :new }

      it { expect(assigns(:article)).to be_a_new Article }
      it { expect(response).to render_template 'new' }
    end
  
    describe "GET edit" do
      before { get :edit, id: authors_article.to_param }

      it { expect(assigns(:article)).to eq authors_article }
      it { expect(response).to render_template 'edit' }
    end
  
    describe "POST create" do
      subject { post :create, article: article_attributes }

      describe "with valid params" do
        let(:title) { 'The Sex Life of the Ping Pong Ball' }
        let(:article_attributes) { { title: title } }
        let(:created_article) { Article.last }

        it "creates a new Article" do
          expect {
            subject
          }.to change(Article, :count).by(1)
        end

        describe "and" do
          before { subject }

          it { expect(assigns :article).to eq created_article }
          it { expect(created_article.author_id).to eq author.id }
          it { expect(created_article.title).to eq title }
          it { should redirect_to created_article }
          it { expect(flash[:notice]).to be_present }
        end
      end
  
      describe "with invalid params" do
        let(:article_attributes) { {title: nil} }
        before { subject }

        it { expect(assigns(:article)).to be_a_new Article }
        it { expect(response).to render_template 'new' }
      end
    end
  
    describe "PUT update" do
      subject { patch :update, id: authors_article.to_param, article: article_attributes }

      describe "with valid params" do
        let(:new_body) { 'New Body' }
        let(:article_attributes) { { body: new_body } }
        before { subject }

        it { expect(authors_article.reload.body).to eq new_body }
        it { expect(assigns(:article)).to eq authors_article }
        it { expect(response).to redirect_to authors_article }
        it { expect(flash[:notice]).to be_present }
      end
  
      describe "with invalid params" do
        let(:article_attributes) { { title: nil } }
        before { subject }

        it { expect(assigns(:article)).to eq authors_article }
        it { expect(response).to render_template 'edit' }
      end
    end
  
    describe "DELETE destroy" do
      subject { delete :destroy, id: authors_article.to_param }

      it "destroys the requested article"  do
        expect { subject }.to change(Article, :count).by(-1)
      end

      describe "and" do
        before { subject }

        it { response.should redirect_to articles_url }
        it { expect(flash[:notice]).to be_present }
      end
    end

    describe "PATCH publish" do
      let(:article) { authors_article }

      subject { patch :publish, id: article.to_param }

      context "for an already published article" do
        before { article.update_column :published_at, 1.day.ago }

        it "should not change the article's published_at" do
          expect {
            subject
          }.not_to change(article.reload, :published_at)
        end
      end

      context "for an unpublished article" do
        it "should set published_at" do
          subject
          expect(article.reload.published_at).to be_within(3.seconds).of(Time.now)
        end

        context "and" do
          before { subject }
          it { expect(flash[:notice]).to be_present }
          it { expect(response).to redirect_to authors_article }
        end
      end
    end
  end
end
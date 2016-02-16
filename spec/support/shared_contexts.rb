RSpec.shared_context 'a successful index request' do
  it 'returns an successful status code' do
    expect(subject).to be_success
  end

  it 'renders the index template' do
    expect(subject).to render_template 'index'
  end
end

RSpec.shared_context 'a successful edit request' do
  it 'returns an successful status code' do
    expect(subject).to be_success
  end

  it 'renders the index template' do
    expect(subject).to render_template 'edit'
  end
end

RSpec.shared_context 'a successful new request' do
  it 'returns an successful status code' do
    expect(subject).to be_success
  end

  it 'renders the index template' do
    expect(subject).to render_template 'new'
  end
end

RSpec.shared_context 'a successful create request' do
  it 'redirects' do
    expect(subject).to be_redirect
  end
end

RSpec.shared_context 'an unsuccessful create request' do
  it 'returns an successful status code' do
    expect(subject).to be_success
  end

  it 'renders the index template' do
    expect(subject).to render_template 'new'
  end
end

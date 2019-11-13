# coding: utf-8
Pod::Spec.new do |spec|
  spec.name         = 'JEKScrollableSectionCollectionViewLayout'
  spec.version      = '1.3.0'
  spec.platform     = :ios, '9.1'
  spec.homepage     = 'https://github.com/accatyyc/JEKScrollableSectionCollectionViewLayout'
  spec.authors      = { 'Joel Ekström' => 'accatyyc@gmail.com' }
  spec.summary      = 'A UICollectionView flow layout with individually scrollable sections'
  spec.license      = 'MIT'
  spec.source       = { :git => 'https://github.com/accatyyc/JEKScrollableSectionCollectionViewLayout.git', :tag => "v#{spec.version}" }
  spec.source_files = 'JEKScrollableSectionCollectionViewLayout.{h,m}'
  spec.frameworks   = 'Foundation', 'UIKit'
end

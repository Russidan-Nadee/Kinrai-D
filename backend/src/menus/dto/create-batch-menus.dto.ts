import { Type } from 'class-transformer';
import { IsArray, ValidateNested, ArrayMinSize, ArrayMaxSize } from 'class-validator';
import { CreateMenuDto } from './create-menu.dto';

export class CreateBatchMenusDto {
  @IsArray()
  @ArrayMinSize(1, { message: 'At least one menu is required' })
  @ArrayMaxSize(100, { message: 'Maximum 100 menus per batch' })
  @ValidateNested({ each: true })
  @Type(() => CreateMenuDto)
  menus: CreateMenuDto[];
}
